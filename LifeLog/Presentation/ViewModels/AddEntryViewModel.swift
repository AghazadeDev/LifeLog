import Foundation
import SwiftData
import Observation

@Observable
final class AddEntryViewModel {
    var entryText = ""
    var speechRecognizer = SpeechRecognizer()

    private let journalUseCase: JournalUseCase
    private var onSave: (() -> Void)?

    init(modelContext: ModelContext, onSave: (() -> Void)? = nil) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        self.onSave = onSave
    }

    var canSave: Bool {
        !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
            if !speechRecognizer.transcript.isEmpty {
                if !entryText.isEmpty {
                    entryText += " "
                }
                entryText += speechRecognizer.transcript
            }
        } else {
            Task {
                let authorized = await speechRecognizer.requestAuthorization()
                if authorized {
                    speechRecognizer.startRecording()
                } else {
                    speechRecognizer.errorMessage = "Microphone permission denied"
                }
            }
        }
    }

    func saveEntry() {
        let trimmed = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        journalUseCase.addEntry(text: trimmed)
        entryText = ""
        speechRecognizer.transcript = ""
        onSave?()
    }
}
