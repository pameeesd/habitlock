import SwiftUI
import SwiftData

/// Formulario modal para crear o editar hábitos y tareas.
struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.title) private var existingHabits: [Habit]
    
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedHabitTitle: String = "Salud y Bienestar"
    @State private var markerType: String = "dot" // "dot", "ring", "square"
    @State private var alarmOffsetMinutes: Int = 15
    @State private var enableAlarm: Bool = true
    
    let markerTypes = [
        ("Punto (Dot)", "dot", "circle.fill"),
        ("Anillo (Ring)", "ring", "circle"),
        ("Cuadrado (Square)", "square", "square.fill")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles de la Tarea") {
                    TextField("Título de la tarea (máx. 45 caracteres)", text: $title)
                        .font(HabitLockTypography.taskBody)
                        .onChange(of: title) { _, newValue in
                            if newValue.count > 45 {
                                title = String(newValue.prefix(45))
                            }
                        }
                    
                    Picker("Categoría / Hábito", selection: $selectedHabitTitle) {
                        Text("Salud y Bienestar").tag("Salud y Bienestar")
                        Text("Productividad").tag("Productividad")
                        Text("Rutina Personal").tag("Rutina Personal")
                        ForEach(existingHabits, id: \.id) { h in
                            Text(h.title).tag(h.title)
                        }
                    }
                    
                    Picker("Marcador del Día", selection: $markerType) {
                        ForEach(markerTypes, id: \.1) { name, key, icon in
                            Label(name, systemImage: icon).tag(key)
                        }
                    }
                }
                
                Section("Fecha y Alerta Previas") {
                    DatePicker("Hora programada", selection: $dueDate, displayedComponents: [.hourAndMinute, .date])
                    
                    Toggle("Activar Alerta Previa", isOn: $enableAlarm)
                    
                    if enableAlarm {
                        Picker("Notificar antes", selection: $alarmOffsetMinutes) {
                            Text("5 minutos antes").tag(5)
                            Text("15 minutos antes").tag(15)
                            Text("30 minutos antes").tag(30)
                        }
                    }
                }
            }
            .navigationTitle("Nuevo Registro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        // Recuperar o crear el Hábito asociado
        let parentHabit = existingHabits.first(where: { $0.title == selectedHabitTitle }) ?? Habit(
            title: selectedHabitTitle,
            markerType: markerType,
            hexColor: "#8FBC8F"
        )
        
        let newTask = HabitTask(
            title: title,
            dueDate: dueDate,
            isCompleted: false,
            alarmOffsetMinutes: enableAlarm ? alarmOffsetMinutes : nil,
            category: selectedHabitTitle,
            habit: parentHabit
        )
        
        modelContext.insert(parentHabit)
        modelContext.insert(newTask)
        try? modelContext.save()
        
        if enableAlarm {
            LocalNotificationManager.shared.scheduleTaskReminder(task: newTask)
        }
        
        dismiss()
    }
}
