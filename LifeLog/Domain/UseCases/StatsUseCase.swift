import Foundation

struct JournalStats {
    let totalDays: Int
    let currentStreak: Int
    let longestStreak: Int
}

struct StatsUseCase {
    func calculate(from days: [DayEntry]) -> JournalStats {
        guard !days.isEmpty else {
            return JournalStats(totalDays: 0, currentStreak: 0, longestStreak: 0)
        }

        let calendar = Calendar.current
        let sortedDates = days
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)

        let totalDays = sortedDates.count

        var currentStreak = 0
        let today = calendar.startOfDay(for: .now)

        // Current streak: count consecutive days ending today or yesterday
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

        // Longest streak
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

        return JournalStats(
            totalDays: totalDays,
            currentStreak: currentStreak,
            longestStreak: longestStreak
        )
    }
}
