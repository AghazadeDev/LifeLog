import Foundation
import SwiftData
import Observation

@Observable
final class HistoryViewModel {
    var days: [DayEntry] = []
    var exportFileURL: URL?
    var showShareSheet = false

    private let journalUseCase: JournalUseCase
    private let exportUseCase = ExportUseCase()

    init(modelContext: ModelContext) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        loadDays()
    }

    func loadDays() {
        days = journalUseCase.fetchAllDays()
    }

    func notesForDay(_ day: DayEntry) -> [NoteEntry] {
        journalUseCase.notesForDay(day)
    }

    func deleteNote(_ note: NoteEntry) {
        journalUseCase.deleteNote(note)
        loadDays()
    }

    func exportJournal() {
        exportFileURL = exportUseCase.export(days: days)
        if exportFileURL != nil {
            showShareSheet = true
        }
    }
}
