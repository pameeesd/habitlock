import SwiftUI
import SwiftData

/// Vista principal de la agenda y seguimiento de hábitos diaria/semanal.
/// Implementa las zonas de alcance ergonómico (Zona Cálida con botón flotante + en la parte inferior).
struct MainAgendaView: View {
    @Query(sort: \HabitTask.dueDate, order: .forward) private var tasks: [HabitTask]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDayTitle: String? = nil
    @State private var isZoomed: Bool = false
    @State private var showForm: Bool = false
    
    var body: some View {
        ZStack {
            Color.creamWhite.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Zona Fría (Títulos estáticos de lectura)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HABITLOCK")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.sageGreen)
                            .tracking(2)
                        
                        Text("Tu Agenda y Hábitos")
                            .font(HabitLockTypography.sectionHeader)
                            .foregroundColor(.forestPine)
                    }
                    Spacer()
                }
                .padding()
                
                // Zona Templada (Visualizador semanal con indicadores de hábito)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["Lunes 10", "Martes 11", "Miércoles 12", "Jueves 13", "Viernes 14", "Sábado 15", "Domingo 16"], id: \.self) { day in
                            Button(action: {
                                selectedDayTitle = day
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isZoomed = true
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Text(day.prefix(3).uppercased())
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(day.contains("10") ? .forestPine : .secondary)
                                    
                                    Text(day.components(separatedBy: " ").last ?? "")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(day.contains("10") ? .forestPine : .primary)
                                    
                                    // Marcador de hábito (dot, ring, square)
                                    Circle()
                                        .fill(day.contains("10") ? Color.sageGreen : Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                                .frame(width: 54, height: 66)
                                .background(day.contains("10") ? Color.eucalyptusMint.opacity(0.4) : Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Zona Cálida (Lista de tareas e interacción con el pulgar)
                List {
                    if tasks.isEmpty {
                        ContentUnavailableView(
                            "Sin Tareas Registradas",
                            systemImage: "leaf",
                            description: Text("Toca el botón + para agregar tu primer hábito o evento.")
                        )
                    } else {
                        Section("Pendientes de Hoy") {
                            ForEach(tasks, id: \.id) { task in
                                HStack {
                                    Button(action: {
                                        task.isCompleted.toggle()
                                        if task.isCompleted {
                                            task.streakCount += 1
                                        }
                                        try? modelContext.save()
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(task.isCompleted ? .sageGreen : .forestPine)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title)
                                            .font(HabitLockTypography.taskBody)
                                            .strikethrough(task.isCompleted, color: .sageGreen)
                                            .foregroundColor(task.isCompleted ? .sageGreen : .forestPine)
                                        
                                        HStack(spacing: 6) {
                                            if let habit = task.habit {
                                                Text(habit.title)
                                                    .font(HabitLockTypography.caption)
                                                    .foregroundColor(.sageGreen)
                                                    .bold()
                                            } else {
                                                Text(task.category)
                                                    .font(HabitLockTypography.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if task.streakCount > 0 {
                                        HStack(spacing: 2) {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(.orange)
                                            Text("\(task.streakCount)")
                                                .font(HabitLockTypography.caption)
                                        }
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(task)
                                        try? modelContext.save()
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            
            // Overlay para la tarjeta modal glassmorphic de zoom centrada
            if isZoomed, let title = selectedDayTitle {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isZoomed = false
                        }
                    }
                
                CustomGlassmorphicContainerView(
                    dayTitle: title,
                    tasks: tasks,
                    onClose: {
                        withAnimation {
                            isZoomed = false
                        }
                    },
                    onToggleTask: { task in
                        task.isCompleted.toggle()
                        try? modelContext.save()
                    }
                )
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
            
            // Botón Flotante (+) en la Zona Cálida Ergonómica
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showForm = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.sageGreen)
                            .clipShape(Circle())
                            .shadow(color: Color.sageGreen.opacity(0.4), radius: 10, x: 0, y: 6)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showForm) {
            HabitFormView()
        }
    }
}
