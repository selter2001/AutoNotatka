import AVFoundation

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()

    @Published private(set) var isMicrophoneGranted: Bool = false

    private init() {
        refreshStatus()
    }

    var allPermissionsGranted: Bool {
        isMicrophoneGranted
    }

    var needsPermissions: Bool {
        !isMicrophoneGranted
    }

    func refreshStatus() {
        isMicrophoneGranted = AVAudioApplication.shared.recordPermission == .granted
    }

    func requestAllPermissions() async {
        await requestMicrophonePermission()
    }

    func requestMicrophonePermission() async {
        let granted = await AVAudioApplication.requestRecordPermission()
        isMicrophoneGranted = granted
    }

    var microphoneStatusText: String {
        isMicrophoneGranted ? "Przyznano" : "Nie przyznano"
    }
}
