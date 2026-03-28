import Foundation
import SwiftData
import Observation

@Observable
final class TodayViewModel {
    var todayNotes: [NoteEntry] = []
    var pinnedNotes: [NoteEntry] = []
    var showAddEntry = false
    var dailyPrompt: String = ""

    private let journalUseCase: JournalUseCase
    private let promptService = JournalPromptService()

    init(modelContext: ModelContext) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        loadNotes()
        dailyPrompt = promptService.todayPrompt()
    }

    func loadNotes() {
        let allNotes = journalUseCase.fetchTodayNotes()
        pinnedNotes = allNotes.filter { $0.isPinned }
        todayNotes = allNotes.filter { !$0.isPinned }
    }

    func deleteNote(_ note: NoteEntry) {
        journalUseCase.deleteNote(note)
        loadNotes()
    }

    func togglePin(_ note: NoteEntry) {
        journalUseCase.togglePin(note)
        loadNotes()
    }
}
