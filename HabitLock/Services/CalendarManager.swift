import Foundation
import EventKit
import Combine

/// Gestor de sincronización de calendarios nativos y externos (Apple Calendar, Google Calendar) vía EventKit.
class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    
    @Published var currentWeekEvents: [EKEvent] = []
    @Published var isAccessGranted: Bool = false
    
    init() {
        requestAccessAndFetch()
        setupChangeObserver()
    }
    
    /// Solicita autorización de acceso completo a calendarios (iOS 17+)
    func requestAccessAndFetch() {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.isAccessGranted = granted
                    if granted {
                        self?.fetchCurrentWeekEvents()
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.isAccessGranted = granted
                    if granted {
                        self?.fetchCurrentWeekEvents()
                    }
                }
            }
        }
    }
    
    /// Consulta eventos comprendidos en el rango de la semana actual (Lunes a Domingo)
    func fetchCurrentWeekEvents() {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            return
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfWeek, end: endOfWeek, calendars: nil)
        
        DispatchQueue.main.async {
            self.currentWeekEvents = self.eventStore.events(matching: predicate)
        }
    }
    
    /// Escucha la notificación de cambios externos del sistema .EKEventStoreChanged
    private func setupChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged(_:)),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        fetchCurrentWeekEvents()
    }
}
