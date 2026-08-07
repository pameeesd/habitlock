import SwiftUI

/// Componente de tarjeta modal de zoom centrada con efecto glassmorphic ultraThinMaterial.
/// Cumple con la especificación de escala tipográfica (SF Pro Display 16pt / SF Pro Text 14pt).
struct CustomGlassmorphicContainerView: View {
    let dayTitle: String
    let tasks: [HabitTask]
    let onClose: () -> Void
    let onToggleTask: (HabitTask) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Encabezado del contenedor de zoom
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayTitle)
                        .font(HabitLockTypography.zoomTitle)
                        .foregroundColor(.forestPine)
                    
                    Text("Agenda y Hábitos del día")
                        .font(HabitLockTypography.caption)
                        .foregroundColor(.forestPine.opacity(0.7))
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.forestPine.opacity(0.6))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Lista de tareas macheables
            if tasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(.sageGreen)
                    Text("Día libre sin compromisos")
                        .font(HabitLockTypography.taskBody)
                        .foregroundColor(.forestPine.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(tasks, id: \.id) { task in
                            HStack(spacing: 10) {
                                Button(action: {
                                    onToggleTask(task)
                                }) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(task.isCompleted ? .sageGreen : .forestPine)
                                }
                                .buttonStyle(.plain)
                                
                                Text(task.title)
                                    .font(HabitLockTypography.taskBody)
                                    .strikethrough(task.isCompleted, color: .sageGreen)
                                    .foregroundColor(task.isCompleted ? .sageGreen : .forestPine)
                                
                                Spacer()
                                
                                if task.streakCount > 0 {
                                    HStack(spacing: 2) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.orange)
                                        Text("\(task.streakCount)")
                                            .font(HabitLockTypography.caption)
                                            .foregroundColor(.forestPine.opacity(0.8))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white.opacity(0.3))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: 290, height: 290)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 10)
    }
}
