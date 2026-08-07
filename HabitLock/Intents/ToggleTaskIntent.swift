import AppIntents
import WidgetKit
import SwiftData
import Foundation

/// App Intent interactivo para iOS 17 que permite marcar/desmarcar tareas directamente desde el Lock Screen Widget.
struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Completar Tarea en HabitLock"
    
    @Parameter(title: "ID de Tarea")
    var taskId: UUID
    
    init() {}
    
    init(taskId: UUID) {
        self.taskId = taskId
    }
    
    func perform() async throws -> some IntentResult {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
        ) else {
            return .result()
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent(AppConstants.databaseFilename)
        let config = ModelConfiguration(url: storeURL)
        
        do {
            let container = try ModelContainer(for: Schema([HabitTask.self]), configurations: [config])
            let context = ModelContext(container)
            
            let fetchDescriptor = FetchDescriptor<HabitTask>()
            if let allTasks = try? context.fetch(fetchDescriptor) {
                if let taskToUpdate = allTasks.first(where: { $0.id == taskId }) {
                    taskToUpdate.isCompleted.toggle()
                    if taskToUpdate.isCompleted {
                        taskToUpdate.streakCount += 1
                    }
                    try? context.save()
                }
            }
            
            // Recargar timelines de los widgets en la pantalla de bloqueo
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error en perform() de ToggleTaskIntent: \(error)")
        }
        
        return .result()
    }
}
