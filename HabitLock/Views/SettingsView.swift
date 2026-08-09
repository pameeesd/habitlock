import SwiftUI

/// Vista de configuración e instrucciones para la integración con Widgets de Pantalla de Bloqueo de iOS.
struct SettingsView: View {
    @ObservedObject var calendarManager = CalendarManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Label {
                            Text("Cómo agregar Widgets a tu Pantalla de Bloqueo")
                                .font(.headline)
                                .foregroundColor(.forestPine)
                        } icon: {
                            Image(systemName: "lock.rectangle.on.rectangle")
                                .foregroundColor(.sageGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            instructionRow(number: "1", text: "Mantén presionada la pantalla de bloqueo de tu iPhone y pulsa \"Personalizar\".")
                            instructionRow(number: "2", text: "Toca el área de widgets e introduce \"HabitLock\".")
                            instructionRow(number: "3", text: "Elige el widget rectangular de tareas o el circular de progreso.")
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Integración con Lock Screen")
                } footer: {
                    Text("Los widgets se actualizan automáticamente cada 15 minutos.")
                }
                
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16))
                            .foregroundColor(.sageGreen)
                            .frame(width: 28)
                        
                        Text("Acceso a Calendarios")
                            .foregroundColor(.forestPine)
                        
                        Spacer()
                        
                        Image(systemName: calendarManager.isAccessGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(calendarManager.isAccessGranted ? .sageGreen : .red)
                    }
                    
                    Button(action: {
                        LocalNotificationManager.shared.requestAuthorization()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 16))
                                .foregroundColor(.sageGreen)
                                .frame(width: 28)
                            
                            Text("Solicitar Permisos de Notificación")
                                .foregroundColor(.forestPine)
                        }
                    }
                } header: {
                    Text("Permisos y Sincronización")
                } footer: {
                    Text("HabitLock utiliza EventKit para sincronizar con tus calendarios y notificaciones locales para recordatorios.")
                }
                
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.sageGreen)
                            .frame(width: 28)
                        
                        Text("Versión")
                            .foregroundColor(.forestPine)
                        
                        Spacer()
                        
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.system(size: 16))
                            .foregroundColor(.sageGreen)
                            .frame(width: 28)
                        
                        Text("App Group")
                            .foregroundColor(.forestPine)
                        
                        Spacer()
                        
                        Text(AppConstants.appGroupIdentifier)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                } header: {
                    Text("Acerca de")
                }
            }
            .navigationTitle("Ajustes")
        }
    }
    
    // MARK: - Helper Views
    
    private func instructionRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.sageGreen)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
