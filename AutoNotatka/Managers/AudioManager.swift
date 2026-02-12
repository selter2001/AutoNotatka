import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private(set) var currentRecordingURL: URL?

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

    // MARK: - Recording

    func startRecording(fileName: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
        audioRecorder?.record()
        currentRecordingURL = audioURL

        print("[Audio] Recording started: \(fileName)")
        return audioURL
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil

        let url = currentRecordingURL
        currentRecordingURL = nil

        if let url = url {
            print("[Audio] Recording stopped: \(url.lastPathComponent)")
        }
        return url
    }

    func deleteRecordingFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
