import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReminders(for note: Note) -> [String] {
        guard let eventDate = note.eventDate else { return [] }
        
        // Cancel any existing ones first (handled in ViewModel usually, but good to be safe)
        cancelReminders(ids: note.reminderIDs)
        
        var scheduledIDs: [String] = []
        
        let content = UNMutableNotificationContent()
        content.title = note.title.isEmpty ? "NoteZy Reminder" : note.title
        content.body = note.content
        content.sound = .default
        
        // 1. One week before
        if let weekBefore = Calendar.current.date(byAdding: .day, value: -7, to: eventDate), weekBefore > Date() {
            let id = "\(note.id.uuidString)_week"
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: weekBefore),
                repeats: false
            )
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            scheduledIDs.append(id)
        }
        
        // 2. Exact event time
        if eventDate > Date() {
            let id = "\(note.id.uuidString)_event"
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: eventDate),
                repeats: false
            )
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            scheduledIDs.append(id)
        }
        
        return scheduledIDs
    }
    
    func cancelReminders(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
