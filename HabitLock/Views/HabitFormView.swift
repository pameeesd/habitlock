import SwiftUI
import SwiftData

/// Formulario modal para crear o editar hábitos y tareas.
struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var category: String = "Hábito"
    @State private var alarmOffsetMinutes: Int = 5
    @State private var enableAlarm: Bool = true
    
    let categories = ["Hábito", "Agenda", "Salud", "Personal", "Trabajo"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles") {
                    TextField("Nombre de la tarea o hábito", text: $title)
                        .font(HabitLockTypography.taskBody)
                    
                    Picker("Categoría", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                
                Section("Fecha y Hora") {
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
        let newTask = HabitTask(
            title: title,
            isCompleted: false,
            dueDate: dueDate,
            alarmOffsetMinutes: enableAlarm ? alarmOffsetMinutes : nil,
            category: category
        )
        
        modelContext.insert(newTask)
        try? modelContext.save()
        
        if enableAlarm {
            LocalNotificationManager.shared.scheduleTaskReminder(task: newTask)
        }
        
        dismiss()
    }
}
