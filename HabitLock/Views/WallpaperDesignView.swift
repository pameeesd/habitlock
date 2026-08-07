import SwiftUI

/// Vista plantilla en relación de aspecto 9:16 renderizada por ImageRenderer para generar el fondo de pantalla de bloqueo.
struct WallpaperDesignView: View {
    let tasks: [HabitTask]
    
    var body: some View {
        ZStack {
            // Fondo degradado orgánico suave
            LinearGradient(
                colors: [Color.mossCharcoal, Color.forestPine],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 120) // Margen superior para el reloj de iOS Lock Screen
                
                // Franja Semanal
                VStack(spacing: 8) {
                    Text("HABITLOCK AGENDA")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.eucalyptusMint)
                        .tracking(2)
                    
                    HStack(spacing: 12) {
                        ForEach(["L", "M", "M", "J", "V", "S", "D"], id: \.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.creamWhite)
                                .frame(width: 32, height: 32)
                                .background(day == "L" ? Color.sageGreen : Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                
                // Tarjeta Principal de Tareas para la Pantalla de Bloqueo
                VStack(alignment: .leading, spacing: 14) {
                    Text("Hoy")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.forestPine)
                    
                    if tasks.isEmpty {
                        Text("No hay tareas pendientes para hoy")
                            .font(.system(size: 14))
                            .foregroundColor(.forestPine.opacity(0.7))
                    } else {
                        ForEach(tasks.prefix(5), id: \.id) { task in
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .sageGreen : .forestPine)
                                Text(task.title)
                                    .font(.system(size: 14, weight: .regular))
                                    .strikethrough(task.isCompleted, color: .sageGreen)
                                    .foregroundColor(task.isCompleted ? .sageGreen : .forestPine)
                            }
                        }
                    }
                }
                .padding(20)
                .frame(width: 320)
                .background(Color.creamWhite.opacity(0.9))
                .cornerRadius(24)
                .shadow(radius: 10)
                
                Spacer()
            }
            .padding()
        }
    }
}
