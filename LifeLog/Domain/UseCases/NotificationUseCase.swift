import UserNotifications

struct NotificationUseCase {
    func requestAndSchedule() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            scheduleDailyReminder(center: center)
            scheduleStreakReminder(center: center)
        }
    }

    private func scheduleDailyReminder(center: UNUserNotificationCenter) {
        let lang = LanguageManager.shared
        let content = UNMutableNotificationContent()
        content.title = lang.localizedString("notification.title")
        content.body = lang.localizedString("notification.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        center.add(request)
    }

    private func scheduleStreakReminder(center: UNUserNotificationCenter) {
        let lang = LanguageManager.shared
        let content = UNMutableNotificationContent()
        content.title = lang.localizedString("notification.streak.title")
        content.body = lang.localizedString("notification.streak.body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak-reminder", content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: ["streak-reminder"])
        center.add(request)
    }
}
