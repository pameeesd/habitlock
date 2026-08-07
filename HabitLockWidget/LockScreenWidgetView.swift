import SwiftUI
import WidgetKit

/// Interfaz del widget interactivo para la Pantalla de Bloqueo (accessoryRectangular).
struct LockScreenWidgetView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                    Text("HABITLOCK")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .foregroundColor(.secondary)
                
                if entry.tasks.isEmpty {
                    Text("Sin tareas pendientes")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                } else {
                    ForEach(entry.tasks.prefix(2), id: \.id) { task in
                        HStack(spacing: 6) {
                            Button(intent: ToggleTaskIntent(taskId: task.id)) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            
                            Text(task.title)
                                .font(.system(size: 11, weight: task.isCompleted ? .regular : .medium))
                                .strikethrough(task.isCompleted)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .widgetAccentable()
            
        case .accessoryCircular:
            VStack {
                let completed = entry.tasks.filter { $0.isCompleted }.count
                let total = max(entry.tasks.count, 1)
                Text("\(completed)/\(total)")
                    .font(.system(size: 14, weight: .bold))
                Image(systemName: "leaf.fill")
                    .font(.system(size: 10))
            }
            
        default:
            VStack(alignment: .leading) {
                Text("HabitLock")
                    .font(.headline)
                Text("\(entry.tasks.count) tareas hoy")
                    .font(.subheadline)
            }
        }
    }
}
