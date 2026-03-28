import Foundation
import SwiftData

struct JournalUseCase {
    let modelContext: ModelContext

    func addEntry(text: String, date: Date = .now) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let dayEntry = fetchOrCreateDay(for: startOfDay)
        let note = NoteEntry(text: text, createdAt: date)
        note.dayEntry = dayEntry
        dayEntry.notes.append(note)
        modelContext.insert(note)
        try? modelContext.save()
    }

    func fetchOrCreateDay(for date: Date) -> DayEntry {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let day = DayEntry(date: startOfDay)
        modelContext.insert(day)
        return day
    }

    func fetchTodayNotes() -> [NoteEntry] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)

        guard let day = try? modelContext.fetch(descriptor).first else { return [] }
        return day.notes.sorted { $0.createdAt < $1.createdAt }
    }

    func fetchAllDays() -> [DayEntry] {
        let descriptor = FetchDescriptor<DayEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func notesForDay(_ day: DayEntry) -> [NoteEntry] {
        day.notes.sorted { $0.createdAt < $1.createdAt }
    }
}
