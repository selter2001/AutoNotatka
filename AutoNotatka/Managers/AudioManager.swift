import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private let audioSession = AVAudioSession.sharedInstance()

    private init() {}

    func configureAudioSession() throws {
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func deactivateSession() {
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }

    var isRecordingPermissionGranted: Bool {
        AVAudioApplication.shared.recordPermission == .granted
    }
}
