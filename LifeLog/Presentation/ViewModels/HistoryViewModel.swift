import Foundation
import SwiftData
import Observation

enum HistoryViewMode: String, CaseIterable {
    case list
    case calendar
}

@Observable
final class HistoryViewModel {
    var days: [DayEntry] = []
    var exportFileURL: URL?
    var showShareSheet = false
    var searchText = ""
    var searchResults: [NoteEntry] = []
    var selectedTag: String?
    var allTags: [String] = []
    var viewMode: HistoryViewMode = .list
    var calendarData: [Date: Int] = [:]

    private let journalUseCase: JournalUseCase
    private let exportUseCase = ExportUseCase()
    private let pdfExportUseCase = PDFExportUseCase()

    init(modelContext: ModelContext) {
        self.journalUseCase = JournalUseCase(modelContext: modelContext)
        loadDays()
    }

    func loadDays() {
        days = journalUseCase.fetchAllDays()
        allTags = journalUseCase.fetchAllTags()
        buildCalendarData()
    }

    func notesForDay(_ day: DayEntry) -> [NoteEntry] {
        journalUseCase.notesForDay(day)
    }

    func deleteNote(_ note: NoteEntry) {
        journalUseCase.deleteNote(note)
        loadDays()
    }

    func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        searchResults = journalUseCase.searchNotes(query: query)
    }

    func filterByTag(_ tag: String?) {
        selectedTag = tag
    }

    var filteredDays: [DayEntry] {
        guard let tag = selectedTag else { return days }
        return days.filter { day in
            day.notes.contains { $0.tags.contains(tag) || $0.aiTags.contains(tag) }
        }
    }

    func exportJournal() {
        exportFileURL = exportUseCase.export(days: days)
        if exportFileURL != nil {
            showShareSheet = true
        }
    }

    func exportPDF() {
        exportFileURL = pdfExportUseCase.export(days: days)
        if exportFileURL != nil {
            showShareSheet = true
        }
    }

    private func buildCalendarData() {
        calendarData = [:]
        let calendar = Calendar.current
        for day in days {
            let start = calendar.startOfDay(for: day.date)
            calendarData[start] = day.notes.count
        }
    }
}
