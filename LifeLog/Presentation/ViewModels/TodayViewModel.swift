import Foundation
import SwiftData
import Observation

@Observable
final class TodayViewModel {
    var todayNotes: [NoteEntry] = []
    var showAddEntry = false

    private let journalUseCase: JournalUseCase

    init(modelContext: ModelContext) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        loadNotes()
    }

    func loadNotes() {
        todayNotes = journalUseCase.fetchTodayNotes()
    }

    func deleteNote(_ note: NoteEntry) {
        journalUseCase.deleteNote(note)
        loadNotes()
    }
}
