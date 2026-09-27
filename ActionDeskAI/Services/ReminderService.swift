import UserNotifications

enum ReminderService {
    static func schedule(for item: AdminItem, daysBefore: Int) async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted, let deadline = item.deadline else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification.deadline.title")
        content.body = item.title
        content.sound = .default
        let date = Calendar.current.date(byAdding: .day, value: -daysBefore, to: deadline) ?? deadline
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        try await center.add(UNNotificationRequest(identifier: "deadline-\(item.id)-\(daysBefore)", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)))
    }
}

