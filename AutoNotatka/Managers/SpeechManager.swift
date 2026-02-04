import Speech
import AVFoundation

@MainActor
final class SpeechManager: ObservableObject {
    @Published private(set) var transcribedText: String = ""
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var error: SpeechError?

    private let speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    enum SpeechError: LocalizedError {
        case notAuthorized
        case notAvailable
        case audioEngineError
        case recognitionFailed

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Brak uprawnień do rozpoznawania mowy"
            case .notAvailable:
                return "Rozpoznawanie mowy niedostępne"
            case .audioEngineError:
                return "Błąd silnika audio"
            case .recognitionFailed:
                return "Błąd rozpoznawania mowy"
            }
        }
    }

    init(locale: Locale = Locale(identifier: "pl-PL")) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
    }

    static func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    var isAvailable: Bool {
        speechRecognizer?.isAvailable ?? false
    }

    func startRecording() throws {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            error = .notAvailable
            throw SpeechError.notAvailable
        }

        stopRecording()
        transcribedText = ""
        error = nil

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = speechRecognizer.supportsOnDeviceRecognition

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }

                if let result {
                    self.transcribedText = result.bestTranscription.formattedString
                }

                if error != nil || result?.isFinal == true {
                    self.stopRecording()
                }
            }
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }

    func reset() {
        stopRecording()
        transcribedText = ""
        error = nil
    }
}
