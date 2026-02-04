import SwiftUI
import Speech

@MainActor
final class RecordingViewModel: ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var transcribedText = ""
    @Published private(set) var recordingDuration: TimeInterval = 0
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    @Published private(set) var lastSavedNote: Note?
    @Published var showSaveConfirmation = false

    private let speechManager = SpeechManager()
    private let audioManager = AudioManager.shared
    private let storageManager = CloudStorageManager.shared
    private var recordingStartTime: Date?
    private var durationTimer: Timer?

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

        let speechStatus = await SpeechManager.requestAuthorization()
        guard speechStatus == .authorized else {
            permissionAlertMessage = "Wymagany dostęp do rozpoznawania mowy. Włącz w Ustawieniach."
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
            try speechManager.startRecording()
            isRecording = true
            transcribedText = ""
            recordingStartTime = Date()
            startDurationTimer()
            observeTranscription()
        } catch {
            permissionAlertMessage = "Nie można rozpocząć nagrywania: \(error.localizedDescription)"
            showPermissionAlert = true
        }
    }

    private func stopRecording() {
        guard isRecording else { return }

        speechManager.stopRecording()
        stopDurationTimer()
        isRecording = false

        saveNote()
    }

    private var transcriptionTimer: Timer?

    private func observeTranscription() {
        transcriptionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                if !self.isRecording {
                    timer.invalidate()
                    self.transcriptionTimer = nil
                    return
                }
                self.transcribedText = self.speechManager.transcribedText
            }
        }
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

    private func saveNote() {
        guard !transcribedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let note = Note(
            id: UUID(),
            content: transcribedText,
            createdAt: recordingStartTime ?? Date(),
            duration: recordingDuration
        )

        do {
            try storageManager.saveNote(note)
            lastSavedNote = note
            showSaveConfirmation = true

            // Auto-hide confirmation
            Task {
                try? await Task.sleep(for: .seconds(2))
                showSaveConfirmation = false
            }
        } catch {
            permissionAlertMessage = "Nie udało się zapisać notatki: \(error.localizedDescription)"
            showPermissionAlert = true
        }
    }

    func reset() {
        transcribedText = ""
        recordingDuration = 0
        lastSavedNote = nil
    }
}
