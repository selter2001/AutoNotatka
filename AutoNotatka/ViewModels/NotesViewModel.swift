import SwiftUI

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let storageManager = CloudStorageManager.shared

    var isEmpty: Bool {
        notes.isEmpty && !isLoading
    }

    var iCloudStatus: String {
        storageManager.isICloudAvailable ? "iCloud" : "Lokalnie"
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

    func deleteNote(_ note: Note) {
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
}
