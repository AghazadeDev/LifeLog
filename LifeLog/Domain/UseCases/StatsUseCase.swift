import Foundation

public struct JournalStats {
    let totalDays: Int
    let totalNotes: Int
    let currentStreak: Int
    let longestStreak: Int
    let averageNotesPerDay: Double
    let moodDistribution: [String: Int]
    let moodTrend: [(date: Date, mood: String)]
    let topTags: [(tag: String, count: Int)]
}

struct StatsUseCase {
    func calculate(from days: [DayEntry]) -> JournalStats {
        guard !days.isEmpty else {
            return JournalStats(totalDays: 0, totalNotes: 0, currentStreak: 0,
                                longestStreak: 0, averageNotesPerDay: 0,
                                moodDistribution: [:], moodTrend: [], topTags: [])
        }

        let calendar = Calendar.current
        let sortedDates = days
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)

        let totalDays = sortedDates.count
        let allNotes = days.flatMap { $0.notes }
        let totalNotes = allNotes.count
        let averageNotesPerDay = totalDays > 0 ? Double(totalNotes) / Double(totalDays) : 0

        var currentStreak = 0
        let today = calendar.startOfDay(for: .now)

        if let first = sortedDates.first,
           let daysDiff = calendar.dateComponents([.day], from: first, to: today).day,
           daysDiff <= 1 {
            currentStreak = 1
            for i in 1..<sortedDates.count {
                if let diff = calendar.dateComponents([.day], from: sortedDates[i], to: sortedDates[i - 1]).day,
                   diff == 1 {
                    currentStreak += 1
                } else {
                    break
                }
            }
        }

        var longestStreak = 1
        var streak = 1
        for i in 1..<sortedDates.count {
            if let diff = calendar.dateComponents([.day], from: sortedDates[i], to: sortedDates[i - 1]).day,
               diff == 1 {
                streak += 1
                longestStreak = max(longestStreak, streak)
            } else {
                streak = 1
            }
        }

        // Mood distribution
        var moodDist: [String: Int] = [:]
        for note in allNotes {
            if let mood = note.mood {
                moodDist[mood, default: 0] += 1
            }
        }

        // Mood trend (one mood per day, using dominant mood)
        let moodTrend: [(Date, String)] = days
            .sorted { $0.date < $1.date }
            .compactMap { day in
                if let mood = day.dominantMood ?? day.notes.compactMap({ $0.mood }).first {
                    return (day.date, mood)
                }
                return nil
            }

        // Top tags
        var tagCounts: [String: Int] = [:]
        for note in allNotes {
            for tag in note.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        let topTags = tagCounts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { (tag: $0.key, count: $0.value) }

        return JournalStats(
            totalDays: totalDays,
            totalNotes: totalNotes,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            averageNotesPerDay: averageNotesPerDay,
            moodDistribution: moodDist,
            moodTrend: moodTrend,
            topTags: topTags
        )
    }
}
