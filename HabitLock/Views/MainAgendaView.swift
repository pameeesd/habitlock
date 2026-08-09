import SwiftUI
import SwiftData

/// Vista principal de la agenda y seguimiento de hábitos diaria/semanal.
/// Implementa las zonas de alcance ergonómico (Zona Cálida con botón flotante + en la parte inferior).
struct MainAgendaView: View {
    @Query(sort: \HabitTask.dueDate, order: .forward) private var tasks: [HabitTask]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedDate: Date = Date()
    @State private var isZoomed: Bool = false
    @State private var showForm: Bool = false
    @State private var showCalendarPicker: Bool = false
    
    // MARK: - Computed Properties
    
    /// Genera una ventana de 7 días centrada en selectedDate (±3 días)
    private var visibleDays: [Date] {
        let calendar = Calendar.current
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: selectedDate)
        }
    }
    
    /// Filtra las tareas que corresponden al día seleccionado usando comparación por día calendario
    private var tasksForSelectedDate: [HabitTask] {
        let calendar = Calendar.current
        return tasks.filter { task in
            calendar.isDate(task.dueDate, inSameDayAs: selectedDate)
        }
    }
    
    /// Título dinámico del día seleccionado
    private var selectedDayTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es")
        formatter.dateFormat = "EEEE d 'de' MMMM"
        return formatter.string(from: selectedDate).capitalized
    }
    
    /// Indica si el día seleccionado es hoy
    private var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    // MARK: - Body
    
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
                
                // Zona Templada (Visualizador semanal dinámico con indicadores de hábito)
                HStack(spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(visibleDays, id: \.self) { day in
                                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                                let isToday = Calendar.current.isDateInToday(day)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selectedDate = day
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text(dayAbbreviation(for: day))
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(isSelected ? .forestPine : .secondary)
                                        
                                        Text(dayNumber(for: day))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(isSelected ? .forestPine : .primary)
                                        
                                        // Marcador: punto si hay tareas ese día
                                        Circle()
                                            .fill(tasksExist(on: day) ? Color.sageGreen : Color.clear)
                                            .frame(width: 5, height: 5)
                                    }
                                    .frame(width: 54, height: 66)
                                    .background(isSelected ? Color.eucalyptusMint.opacity(0.4) : Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                    .overlay(
                                        // Anillo sutil para indicar "hoy" cuando no está seleccionado
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isToday && !isSelected ? Color.sageGreen.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                    )
                                }
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 4)
                    }
                    
                    // Botón de Calendario (fijo a la derecha)
                    Button(action: {
                        showCalendarPicker = true
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.sageGreen)
                            
                            Text("···")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.sageGreen)
                        }
                        .frame(width: 48, height: 66)
                        .background(Color.eucalyptusMint.opacity(0.15))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 16)
                }
                
                // Separador visual entre la tira de días y el contenido de la agenda
                Spacer()
                    .frame(height: 16)
                
                Rectangle()
                    .fill(Color.sageGreen.opacity(0.12))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                
                Spacer()
                    .frame(height: 8)
                
                // Zona Cálida (Lista de tareas filtradas por selectedDate)
                List {
                    if tasksForSelectedDate.isEmpty {
                        ContentUnavailableView(
                            "Sin Tareas Registradas",
                            systemImage: "leaf",
                            description: Text("No hay tareas para \(selectedDayTitle).\nToca el botón + para agregar un hábito o evento.")
                        )
                    } else {
                        Section(isSelectedDateToday ? "Pendientes de Hoy" : selectedDayTitle) {
                            ForEach(tasksForSelectedDate, id: \.id) { task in
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
            if isZoomed {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isZoomed = false
                        }
                    }
                
                CustomGlassmorphicContainerView(
                    dayTitle: selectedDayTitle,
                    tasks: tasksForSelectedDate,
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
        .sheet(isPresented: $showCalendarPicker) {
            calendarPickerSheet
        }
    }
    
    // MARK: - Calendar Picker Sheet
    
    private var calendarPickerSheet: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Seleccionar fecha",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.sageGreen)
                .padding()
                
                Spacer()
            }
            .background(Color.creamWhite)
            .navigationTitle("Ir a fecha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        showCalendarPicker = false
                    }
                    .foregroundColor(.sageGreen)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Retorna la abreviación del día en español (LUN, MAR, etc.)
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    /// Retorna el número del día del mes
    private func dayNumber(for date: Date) -> String {
        let calendar = Calendar.current
        return "\(calendar.component(.day, from: date))"
    }
    
    /// Verifica si existen tareas para un día dado
    private func tasksExist(on date: Date) -> Bool {
        let calendar = Calendar.current
        return tasks.contains { task in
            calendar.isDate(task.dueDate, inSameDayAs: date)
        }
    }
}
