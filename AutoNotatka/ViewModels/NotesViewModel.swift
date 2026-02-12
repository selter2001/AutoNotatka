import SwiftUI

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showRenameAlert = false
    @Published var renameText = ""

    private let storageManager = LocalStorageManager.shared
    private var noteToRename: Note?

    var isEmpty: Bool {
        notes.isEmpty && !isLoading
    }

    func loadNotes() {
        isLoading = true
        errorMessage = nil

        do {
            notes = try storageManager.loadAllNotes()
        } catch {
            errorMessage = "Nie udało się wczytać notatek: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }

    // MARK: - Delete

    func deleteNote(_ note: Note) {
        // Delete from Google Drive if file ID exists
        if let driveFileId = note.driveFileId, !driveFileId.isEmpty {
            GoogleDriveManager.shared.deleteFile(fileId: driveFileId) { result in
                switch result {
                case .success:
                    print("[Notes] Deleted from Drive: \(driveFileId)")
                case .failure(let error):
                    print("[Notes] Drive delete failed: \(error)")
                }
            }
        }

        // Delete locally
        do {
            try storageManager.deleteNote(note)
            notes.removeAll { $0.id == note.id }
        } catch {
            errorMessage = "Nie udało się usunąć notatki: \(error.localizedDescription)"
            showError = true
        }
    }

    func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            deleteNote(notes[index])
        }
    }

    // MARK: - Rename

    func startRename(note: Note) {
        noteToRename = note
        renameText = note.displayName
        showRenameAlert = true
    }

    func confirmRename() {
        guard var note = noteToRename else { return }
        let newName = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newName.isEmpty else { return }

        note.audioFileName = newName
        note.content = "Nagranie: \(newName)"

        do {
            try storageManager.updateNote(note)
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        } catch {
            errorMessage = "Nie udało się zmienić nazwy: \(error.localizedDescription)"
            showError = true
        }

        noteToRename = nil
    }

    // MARK: - Retry Upload

    func retryUpload(note: Note) {
        let folderId = UserDefaults.standard.string(forKey: "selectedDriveFolderId") ?? ""
        guard !folderId.isEmpty, GoogleDriveManager.shared.hasAuthorizer else {
            errorMessage = "Wybierz folder na Dysku Google"
            showError = true
            return
        }

        guard let audioName = note.audioFileName else {
            errorMessage = "Brak pliku audio do wysłania"
            showError = true
            return
        }

        // Check if local audio file still exists
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(audioName)

        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            errorMessage = "Plik audio został usunięty"
            showError = true
            return
        }

        // Update status
        updateNoteStatus(note, status: .uploading)

        GoogleDriveManager.shared.uploadFile(
            localURL: audioURL,
            fileName: audioName,
            mimeType: "audio/m4a",
            parentFolderId: folderId
        ) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }

                switch result {
                case .success(let file):
                    var updated = note
                    updated.driveFileId = file.identifier
                    updated.uploadStatus = .done
                    try? self.storageManager.updateNote(updated)
                    if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                        self.notes[index] = updated
                    }
                    // Clean up local audio
                    try? FileManager.default.removeItem(at: audioURL)
                case .failure:
                    self.updateNoteStatus(note, status: .failed)
                }
            }
        }
    }

    private func updateNoteStatus(_ note: Note, status: UploadStatus) {
        var updated = note
        updated.uploadStatus = status
        try? storageManager.updateNote(updated)
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = updated
        }
    }
}
