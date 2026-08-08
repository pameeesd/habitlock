import AppIntents
import WidgetKit
import SwiftData
import Foundation

/// App Intent interactivo para iOS 17 que permite marcar/desmarcar tareas directamente desde el Lock Screen Widget.
public struct ToggleTaskIntent: AppIntent {
    public static var title: LocalizedStringResource = "Completar Tarea"
    public static var description = IntentDescription("Marca una tarea como completada o pendiente directamente desde el Lock Screen.")
    
    @Parameter(title: "Task ID")
    public var taskId: String
    
    public init() {}
    
    public init(taskId: String) {
        self.taskId = taskId
    }
    
    public init(taskId: UUID) {
        self.taskId = taskId.uuidString
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        guard let targetId = UUID(uuidString: taskId) else {
            return .result()
        }
        
        let container = ModelContainer.sharedContainer
        let context = container.mainContext
        
        let fetchDescriptor = FetchDescriptor<HabitTask>(
            predicate: #Predicate { $0.id == targetId }
        )
        
        if let task = try context.fetch(fetchDescriptor).first {
            task.isCompleted.toggle()
            if task.isCompleted {
                task.streakCount += 1
            }
            try context.save()
            
            // Recargar timelines de los widgets en la pantalla de bloqueo
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        return .result()
    }
}
