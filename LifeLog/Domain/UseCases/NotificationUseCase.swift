import UserNotifications

struct NotificationUseCase {
    func requestAndSchedule() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            scheduleDailyReminder(center: center)
        }
    }

    private func scheduleDailyReminder(center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "LifeLog"
        content.body = "Don't forget to log your day"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        center.add(request)
    }
}
