import Foundation
import SwiftData

@Model
final class DayEntry {
    @Attribute(.unique) var date: Date
    @Relationship(deleteRule: .cascade, inverse: \NoteEntry.dayEntry)
    var notes: [NoteEntry]

    init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
        self.notes = []
    }
}
