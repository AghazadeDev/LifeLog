import Foundation
import SwiftData

struct JournalUseCase {
    let modelContext: ModelContext

    func addEntry(text: String, date: Date = .now, mood: String? = nil,
                  photoData: Data? = nil, tags: [String] = [], isPinned: Bool = false) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let dayEntry = fetchOrCreateDay(for: startOfDay)
        let note = NoteEntry(text: text, createdAt: date, mood: mood,
                             photoData: photoData, tags: tags, isPinned: isPinned)
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

    func fetchPinnedNotes() -> [NoteEntry] {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<DayEntry> { $0.date == startOfDay }
        let descriptor = FetchDescriptor(predicate: predicate)

        guard let day = try? modelContext.fetch(descriptor).first else { return [] }
        return day.notes.filter { $0.isPinned }.sorted { $0.createdAt < $1.createdAt }
    }

    func fetchAllDays() -> [DayEntry] {
        let descriptor = FetchDescriptor<DayEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func notesForDay(_ day: DayEntry) -> [NoteEntry] {
        day.notes.sorted { $0.createdAt < $1.createdAt }
    }

    func deleteNote(_ note: NoteEntry) {
        if let day = note.dayEntry {
            day.notes.removeAll { $0.id == note.id }
            if day.notes.isEmpty {
                modelContext.delete(day)
            }
        }
        modelContext.delete(note)
        try? modelContext.save()
    }

    func togglePin(_ note: NoteEntry) {
        note.isPinned.toggle()
        try? modelContext.save()
    }

    func updateNoteTags(_ note: NoteEntry, tags: [String]) {
        note.tags = tags
        try? modelContext.save()
    }

    func updateNoteAITags(_ note: NoteEntry, aiTags: [String]) {
        note.aiTags = aiTags
        try? modelContext.save()
    }

    func searchNotes(query: String) -> [NoteEntry] {
        let descriptor = FetchDescriptor<NoteEntry>()
        guard let allNotes = try? modelContext.fetch(descriptor) else { return [] }
        let lowered = query.lowercased()
        return allNotes
            .filter { $0.text.localizedCaseInsensitiveContains(lowered) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchNotesByTag(_ tag: String) -> [NoteEntry] {
        let descriptor = FetchDescriptor<NoteEntry>()
        guard let allNotes = try? modelContext.fetch(descriptor) else { return [] }
        return allNotes
            .filter { $0.tags.contains(tag) || $0.aiTags.contains(tag) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func fetchAllTags() -> [String] {
        let descriptor = FetchDescriptor<NoteEntry>()
        guard let allNotes = try? modelContext.fetch(descriptor) else { return [] }
        var tagSet = Set<String>()
        for note in allNotes {
            tagSet.formUnion(note.tags)
            tagSet.formUnion(note.aiTags)
        }
        return tagSet.sorted()
    }

    func updateDaySummary(_ day: DayEntry, summary: String) {
        day.aiSummary = summary
        try? modelContext.save()
    }

    func updateDayDominantMood(_ day: DayEntry) {
        let moods = day.notes.compactMap { $0.mood }
        guard !moods.isEmpty else {
            day.dominantMood = nil
            return
        }
        var counts: [String: Int] = [:]
        for m in moods { counts[m, default: 0] += 1 }
        day.dominantMood = counts.max(by: { $0.value < $1.value })?.key
        try? modelContext.save()
    }
}
