import SwiftUI

/// Vista de configuración e instrucciones para la integración con la app Atajos de iOS.
struct SettingsView: View {
    @State private var shortcutName: String = AppConstants.defaultShortcutName
    @ObservedObject var calendarManager = CalendarManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Integración con Lock Screen") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Configuración del Atajo de iOS")
                            .font(.headline)
                            .foregroundColor(.forestPine)
                        
                        Text("Para permitir que HabitLock actualice tu fondo de pantalla de bloqueo con un solo toque, crea un atajo en la app Atajos de Apple.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Text("Nombre del Atajo")
                        Spacer()
                        TextField("HabitLockWallpaper", text: $shortcutName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.sageGreen)
                    }
                    
                    Button(action: {
                        ShortcutLauncher.launchShortcut(named: shortcutName)
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Probar Ejecución de Atajo")
                        }
                        .foregroundColor(.sageGreen)
                    }
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
