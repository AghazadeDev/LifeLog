import Foundation
import SwiftData
import Observation

@Observable
final class TodayViewModel {
    var todayNotes: [NoteEntry] = []
    var pinnedNotes: [NoteEntry] = []
    var showAddEntry = false
    var dailyPrompt: String = ""
    var dailyInsight: String?
    var isLoadingInsight = false

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

    func loadDailyInsight() {
        guard !isLoadingInsight else { return }
        let allNotes = journalUseCase.fetchTodayNotes()
        guard !allNotes.isEmpty else { return }

        if #available(iOS 26.0, *) {
            Task {
                isLoadingInsight = true
                let ai = AIService()
                dailyInsight = await ai.generateDailyInsight(from: allNotes)
                isLoadingInsight = false
            }
        }
    }
}
