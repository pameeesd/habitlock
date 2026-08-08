import SwiftUI

/// Vista de configuración e instrucciones para la integración con Widgets de Pantalla de Bloqueo de iOS.
struct SettingsView: View {
    @ObservedObject var calendarManager = CalendarManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Integración con Lock Screen (Widgets)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cómo agregar Widgets a tu Pantalla de Bloqueo")
                            .font(.headline)
                            .foregroundColor(.forestPine)
                        
                        Text("1. Mantén presionada la pantalla de bloqueo de tu iPhone y pulsa 'Personalizar'.\n2. Toca el área de widgets e introduce 'HabitLock'.\n3. Elige el widget rectangular de tareas o el circular de progreso.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Permisos y Sincronización") {
                    HStack {
                        Text("Acceso a Calendarios (EventKit)")
                        Spacer()
                        Image(systemName: calendarManager.isAccessGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(calendarManager.isAccessGranted ? .sageGreen : .red)
                    }
                    
                    Button("Solicitar Permisos de Notificación") {
                        LocalNotificationManager.shared.requestAuthorization()
                    }
                }
                
                Section("Acerca de") {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Identificador App Group")
                        Spacer()
                        Text(AppConstants.appGroupIdentifier)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
