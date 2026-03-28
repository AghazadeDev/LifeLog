import Foundation
import SwiftData
import Observation

@Observable
final class AddEntryViewModel {
    var entryText = ""
    var selectedMood: String?
    var selectedPhotoData: Data?
    var selectedTags: [String] = []
    var isPinned = false
    var speechRecognizer = SpeechRecognizer()

    private let journalUseCase: JournalUseCase
    private var onSave: (() -> Void)?
    private var textBeforeRecording = ""

    init(modelContext: ModelContext, onSave: (() -> Void)? = nil) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        self.onSave = onSave
        speechRecognizer.onTranscriptUpdate = { [weak self] transcript in
            guard let self else { return }
            let prefix = self.textBeforeRecording
            self.entryText = prefix.isEmpty ? transcript : prefix + " " + transcript
        }
    }

    var canSave: Bool {
        !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func toggleRecording() {
        if speechRecognizer.isRecording {
            speechRecognizer.stopRecording()
        } else {
            textBeforeRecording = entryText
            Task {
                let authorized = await speechRecognizer.requestAuthorization()
                if authorized {
                    speechRecognizer.startRecording()
                } else {
                    speechRecognizer.errorMessage = LanguageManager.shared.localizedString("speech.error.micDenied")
                }
            }
        }
    }

    func saveEntry() {
        let trimmed = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        journalUseCase.addEntry(
            text: trimmed,
            mood: selectedMood,
            photoData: selectedPhotoData,
            tags: selectedTags,
            isPinned: isPinned
        )
        entryText = ""
        selectedMood = nil
        selectedPhotoData = nil
        selectedTags = []
        isPinned = false
        speechRecognizer.transcript = ""
        onSave?()
    }

    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !selectedTags.contains(trimmed) else { return }
        selectedTags.append(trimmed)
    }

    func removeTag(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
    }
}
