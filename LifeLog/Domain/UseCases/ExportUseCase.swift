import Foundation

struct ExportUseCase {
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    func export(days: [DayEntry]) -> URL? {
        let sorted = days.sorted { $0.date < $1.date }
        var output = ""

        for (index, day) in sorted.enumerated() {
            let dateString = dateFormatter.string(from: day.date)
            let moodStr = day.dominantMood.map { " \($0)" } ?? ""
            output += "=== DATE: \(dateString)\(moodStr) ===\n\n"

            let notes = day.notes.sorted { $0.createdAt < $1.createdAt }
            for note in notes {
                let time = timeFormatter.string(from: note.createdAt)
                let mood = note.mood ?? ""
                let tags = note.tags.isEmpty ? "" : " [Tags: \(note.tags.joined(separator: ", "))]"
                output += "[\(time)] \(mood)\nTEXT: \(note.text)\(tags)\n\n"
            }

            if index < sorted.count - 1 {
                output += "---\n\n"
            }
        }

        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("journal.txt")
        do {
            try output.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
}
