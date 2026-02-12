import SwiftUI

@MainActor
final class RecordingViewModel: ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var recordingDuration: TimeInterval = 0
    @Published private(set) var isUploading = false
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    @Published private(set) var lastSavedNote: Note?
    @Published var showSaveConfirmation = false
    @Published var uploadStatusMessage: String?

    private let audioManager = AudioManager.shared
    private let storageManager = LocalStorageManager.shared
    private var recordingStartTime: Date?
    private var durationTimer: Timer?
    private var currentRecordingURL: URL?

    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func requestPermissions() async {
        let micPermission = await audioManager.requestPermission()
        guard micPermission else {
            permissionAlertMessage = "Wymagany dostęp do mikrofonu. Włącz w Ustawieniach."
            showPermissionAlert = true
            return
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        guard !isRecording else { return }

        do {
            try audioManager.configureAudioSession()

            recordingStartTime = Date()

            // File name = date and time of recording
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let fileName = "\(formatter.string(from: recordingStartTime!)).m4a"

            currentRecordingURL = try audioManager.startRecording(fileName: fileName)

            isRecording = true
            startDurationTimer()
        } catch {
            permissionAlertMessage = "Nie można rozpocząć nagrywania: \(error.localizedDescription)"
            showPermissionAlert = true
        }
    }

    private func stopRecording() {
        guard isRecording else { return }

        stopDurationTimer()
        isRecording = false

        let recordingURL = audioManager.stopRecording()
        audioManager.deactivateSession()

        saveNoteAndUpload(audioURL: recordingURL)
    }

    private func startDurationTimer() {
        recordingDuration = 0
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 1
            }
        }
    }

    private func stopDurationTimer() {
        durationTimer?.invalidate()
        durationTimer = nil
    }

    private func saveNoteAndUpload(audioURL: URL?) {
        guard recordingDuration > 0 else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pl_PL")
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateString = dateFormatter.string(from: recordingStartTime ?? Date())

        let durationMinutes = Int(recordingDuration) / 60
        let durationSeconds = Int(recordingDuration) % 60
        let durationString = String(format: "%d:%02d", durationMinutes, durationSeconds)

        let content = "Nagranie z \(dateString) (czas: \(durationString))"

        let folderId = UserDefaults.standard.string(forKey: "selectedDriveFolderId") ?? ""
        let hasDriveFolder = !folderId.isEmpty && GoogleDriveManager.shared.hasAuthorizer

        let note = Note(
            id: UUID(),
            content: content,
            createdAt: recordingStartTime ?? Date(),
            duration: recordingDuration,
            uploadStatus: hasDriveFolder ? .pending : nil,
            audioFileName: audioURL?.lastPathComponent
        )

        // Save note locally
        do {
            try storageManager.saveNote(note)
            lastSavedNote = note
            showSaveConfirmation = true
        } catch {
            permissionAlertMessage = "Nie udało się zapisać notatki: \(error.localizedDescription)"
            showPermissionAlert = true
        }

        // Upload audio to Google Drive
        guard let audioURL = audioURL else {
            print("[Recording] No audio URL to upload")
            autoHideConfirmation()
            return
        }

        guard hasDriveFolder, !folderId.isEmpty else {
            print("[Recording] No Drive folder selected or no authorizer - skipping upload")
            autoHideConfirmation()
            return
        }

        // Update status to uploading
        if var savedNote = lastSavedNote {
            savedNote.uploadStatus = .uploading
            try? storageManager.updateNote(savedNote)
            lastSavedNote = savedNote
        }

        isUploading = true
        uploadStatusMessage = "Wysyłanie na Dysk Google..."

        let driveFileName = audioURL.lastPathComponent

        GoogleDriveManager.shared.uploadFile(
            localURL: audioURL,
            fileName: driveFileName,
            mimeType: "audio/m4a",
            parentFolderId: folderId
        ) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                self.isUploading = false

                switch result {
                case .success(let file):
                    self.uploadStatusMessage = "Wysłano na Dysk Google"
                    print("[Recording] Upload success: \(file.name ?? "?")")

                    if var savedNote = self.lastSavedNote {
                        savedNote.driveFileId = file.identifier
                        savedNote.uploadStatus = .done
                        try? self.storageManager.updateNote(savedNote)
                        self.lastSavedNote = savedNote
                    }
                case .failure(let error):
                    self.uploadStatusMessage = "Błąd wysyłania: \(error.localizedDescription)"
                    print("[Recording] Upload failed: \(error)")

                    if var savedNote = self.lastSavedNote {
                        savedNote.uploadStatus = .failed
                        try? self.storageManager.updateNote(savedNote)
                        self.lastSavedNote = savedNote
                    }
                }

                self.autoHideConfirmation()

                // Clean up local audio file after successful upload (if setting enabled)
                let deleteLocal = UserDefaults.standard.bool(forKey: "deleteLocalAfterUpload")
                if self.lastSavedNote?.uploadStatus == .done && deleteLocal {
                    self.audioManager.deleteRecordingFile(at: audioURL)
                }
            }
        }
    }

    private func autoHideConfirmation() {
        Task {
            try? await Task.sleep(for: .seconds(3))
            showSaveConfirmation = false
            uploadStatusMessage = nil
        }
    }

    func reset() {
        recordingDuration = 0
        lastSavedNote = nil
        uploadStatusMessage = nil
    }
}
