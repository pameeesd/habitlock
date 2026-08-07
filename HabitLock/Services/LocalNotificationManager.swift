import Foundation
import UserNotifications

/// Gestor de alertas y notificaciones locales 100% offline para HabitLock.
class LocalNotificationManager {
    static let shared = LocalNotificationManager()
    
    private init() {}
    
    /// Solicita permisos de alertas locales al usuario en el primer inicio
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permiso de notificaciones locales concedido.")
            } else if let error = error {
                print("Error al solicitar permisos de notificación: \(error.localizedDescription)")
            }
        }
    }
    
    /// Agenda un aviso local previo (5 o 15 minutos antes de la hora estipulada)
    func scheduleTaskReminder(task: HabitTask) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "HabitLock - Recordatorio"
        content.body = "Próxima tarea: \(task.title)"
        content.sound = .default
        content.userInfo = ["taskId": task.id.uuidString]
        
        let calendar = Calendar.current
        var notificationDate = task.dueDate
        
        if let offset = task.alarmOffsetMinutes {
            notificationDate = calendar.date(byAdding: .minute, value: -offset, to: task.dueDate) ?? task.dueDate
        }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error al agendar notificación local: \(error.localizedDescription)")
            }
        }
    }
    
    /// Cancela recordatorios agendados para tareas eliminadas o completadas
    func cancelReminder(for task: HabitTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
