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
    var isAutoTagging = false

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
                    speechRecognizer.errorMessage = LanguageManager.shared.localizedString("speech.error.micDenied")
                }
            }
        }
    }

    func autoTag() {
        guard !entryText.isEmpty else { return }
        if #available(iOS 26.0, *) {
            Task {
                isAutoTagging = true
                let ai = AIService()
                let tags = await ai.generateTags(for: entryText)
                for tag in tags where !selectedTags.contains(tag) {
                    selectedTags.append(tag)
                }
                isAutoTagging = false
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
