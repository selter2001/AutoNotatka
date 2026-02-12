import Foundation
import Network

final class UploadQueueManager {
    static let shared = UploadQueueManager()

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.autonotatka.networkmonitor")
    private var isConnected = true
    private var isProcessing = false

    private init() {
        startMonitoring()
    }

    // MARK: - Network Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let wasConnected = self?.isConnected ?? true
            self?.isConnected = path.status == .satisfied

            if !wasConnected && path.status == .satisfied {
                print("[Upload Queue] Network restored - processing pending uploads")
                self?.processPendingUploads()
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Queue Processing

    func processPendingUploads() {
        guard !isProcessing else { return }
        guard isConnected else {
            print("[Upload Queue] No network - skipping")
            return
        }
        guard GoogleDriveManager.shared.hasAuthorizer else {
            print("[Upload Queue] No authorizer - skipping")
            return
        }

        let folderId = UserDefaults.standard.string(forKey: "selectedDriveFolderId") ?? ""
        guard !folderId.isEmpty else {
            print("[Upload Queue] No folder selected - skipping")
            return
        }

        isProcessing = true

        // Load notes and find pending/failed ones
        do {
            let notes = try LocalStorageManager.shared.loadAllNotes()
            let pending = notes.filter { $0.uploadStatus == .pending || $0.uploadStatus == .failed }

            if pending.isEmpty {
                print("[Upload Queue] No pending uploads")
                isProcessing = false
                return
            }

            print("[Upload Queue] Found \(pending.count) pending uploads")
            uploadNext(from: pending, index: 0, folderId: folderId)
        } catch {
            print("[Upload Queue] Failed to load notes: \(error)")
            isProcessing = false
        }
    }

    private func uploadNext(from pending: [Note], index: Int, folderId: String) {
        guard index < pending.count else {
            isProcessing = false
            print("[Upload Queue] All pending uploads processed")
            return
        }

        var note = pending[index]
        guard let audioName = note.audioFileName else {
            uploadNext(from: pending, index: index + 1, folderId: folderId)
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(audioName)

        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            // Audio file gone - mark as failed
            note.uploadStatus = .failed
            try? LocalStorageManager.shared.updateNote(note)
            uploadNext(from: pending, index: index + 1, folderId: folderId)
            return
        }

        // Update to uploading
        note.uploadStatus = .uploading
        try? LocalStorageManager.shared.updateNote(note)

        print("[Upload Queue] Uploading: \(audioName)")

        let capturedNote = note
        GoogleDriveManager.shared.uploadFile(
            localURL: audioURL,
            fileName: audioName,
            mimeType: "audio/m4a",
            parentFolderId: folderId
        ) { [weak self] result in
            var updatedNote = capturedNote
            switch result {
            case .success(let file):
                updatedNote.driveFileId = file.identifier
                updatedNote.uploadStatus = .done
                try? LocalStorageManager.shared.updateNote(updatedNote)
                // Clean up local audio if setting enabled
                if UserDefaults.standard.bool(forKey: "deleteLocalAfterUpload") {
                    try? FileManager.default.removeItem(at: audioURL)
                }
                print("[Upload Queue] Upload success: \(audioName)")

            case .failure(let error):
                updatedNote.uploadStatus = .failed
                try? LocalStorageManager.shared.updateNote(updatedNote)
                print("[Upload Queue] Upload failed: \(audioName) - \(error)")
            }

            self?.uploadNext(from: pending, index: index + 1, folderId: folderId)
        }
    }
}
