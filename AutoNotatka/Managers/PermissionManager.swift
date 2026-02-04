import AVFoundation
import Speech

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published private(set) var isMicrophoneGranted: Bool = false
    @Published private(set) var speechStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private init() {
        refreshStatus()
    }

    var allPermissionsGranted: Bool {
        isMicrophoneGranted && speechStatus == .authorized
    }

    var needsPermissions: Bool {
        !isMicrophoneGranted || speechStatus == .notDetermined
    }

    func refreshStatus() {
        isMicrophoneGranted = AVAudioApplication.shared.recordPermission == .granted
        speechStatus = SFSpeechRecognizer.authorizationStatus()
    }

    func requestAllPermissions() async {
        await requestMicrophonePermission()
        await requestSpeechPermission()
    }

    func requestMicrophonePermission() async {
        let granted = await AVAudioApplication.requestRecordPermission()
        isMicrophoneGranted = granted
    }

    func requestSpeechPermission() async {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        speechStatus = status
    }

    var microphoneStatusText: String {
        isMicrophoneGranted ? "Przyznano" : "Nie przyznano"
    }

    var speechStatusText: String {
        switch speechStatus {
        case .notDetermined: return "Nie określono"
        case .denied: return "Odmowa"
        case .restricted: return "Ograniczono"
        case .authorized: return "Przyznano"
        @unknown default: return "Nieznany"
        }
    }
}
