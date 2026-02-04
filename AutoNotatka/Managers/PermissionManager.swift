import AVFoundation
import Speech

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published private(set) var microphoneStatus: AVAudioSession.RecordPermission = .undetermined
    @Published private(set) var speechStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private init() {
        refreshStatus()
    }

    var allPermissionsGranted: Bool {
        microphoneStatus == .granted && speechStatus == .authorized
    }

    var needsPermissions: Bool {
        microphoneStatus == .undetermined || speechStatus == .notDetermined
    }

    func refreshStatus() {
        microphoneStatus = AVAudioSession.sharedInstance().recordPermission
        speechStatus = SFSpeechRecognizer.authorizationStatus()
    }

    func requestAllPermissions() async {
        await requestMicrophonePermission()
        await requestSpeechPermission()
    }

    func requestMicrophonePermission() async {
        let granted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        microphoneStatus = granted ? .granted : .denied
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
        switch microphoneStatus {
        case .undetermined: return "Nie określono"
        case .denied: return "Odmowa"
        case .granted: return "Przyznano"
        @unknown default: return "Nieznany"
        }
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
