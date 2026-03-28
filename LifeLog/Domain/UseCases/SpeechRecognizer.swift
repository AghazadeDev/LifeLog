import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechRecognizer {
    var transcript = ""
    var isRecording = false
    var errorMessage: String?
    var onTranscriptUpdate: ((String) -> Void)?

    private var audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognizer: SFSpeechRecognizer?

    init() {
        speechRecognizer = Self.makeSpeechRecognizer()
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecording() {
        guard !isRecording else { return }

        let lang = LanguageManager.shared

        resetTask()
        transcript = ""
        errorMessage = nil

        speechRecognizer = Self.makeSpeechRecognizer()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = lang.localizedString("speech.error.audioSession")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest, let speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = lang.localizedString("speech.error.unavailable")
            return
        }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            if let result {
                self.transcript = result.bestTranscription.formattedString
                self.onTranscriptUpdate?(self.transcript)
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = lang.localizedString("speech.error.audioEngine")
            resetTask()
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
    }

    private func resetTask() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
    }

    private static func makeSpeechRecognizer() -> SFSpeechRecognizer? {
        let locale = LanguageManager.shared.locale
        if let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable {
            return recognizer
        }
        let fallback = Locale(identifier: "en-US")
        return SFSpeechRecognizer(locale: fallback)
    }
}
