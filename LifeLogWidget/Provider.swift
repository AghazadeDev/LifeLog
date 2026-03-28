import WidgetKit
import Foundation

struct LifeLogEntry: TimelineEntry {
    let date: Date
    let todayCount: Int
    let currentStreak: Int
    let dominantMood: String?
}

struct LifeLogTimelineProvider: TimelineProvider {
    private let suiteName = "group.com.lifelog.shared"

    func placeholder(in context: Context) -> LifeLogEntry {
        LifeLogEntry(date: .now, todayCount: 3, currentStreak: 7, dominantMood: "😊")
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeLogEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeLogEntry>) -> Void) {
        let entry = readEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readEntry() -> LifeLogEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let todayCount = defaults?.integer(forKey: "widget_today_count") ?? 0
        let currentStreak = defaults?.integer(forKey: "widget_current_streak") ?? 0
        let dominantMood = defaults?.string(forKey: "widget_dominant_mood")
        return LifeLogEntry(date: .now, todayCount: todayCount,
                            currentStreak: currentStreak, dominantMood: dominantMood)
    }
}
