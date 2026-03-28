import Foundation
import WidgetKit

struct WidgetDataService {
    private static let suiteName = "group.com.lifelog.shared"

    static func update(todayCount: Int, currentStreak: Int, dominantMood: String?) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return }
        defaults.set(todayCount, forKey: "widget_today_count")
        defaults.set(currentStreak, forKey: "widget_current_streak")
        defaults.set(dominantMood, forKey: "widget_dominant_mood")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
