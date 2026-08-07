import Foundation
import SwiftData

/// Modelo de entidad persistente para hábitos y tareas con SwiftData (iOS 17+).
@Model
final class HabitTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var alarmOffsetMinutes: Int? // ej: 5 o 15 minutos de aviso previo
    var category: String // "Hábito", "Agenda", "Salud"
    var streakCount: Int
    var notes: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        dueDate: Date = Date(),
        alarmOffsetMinutes: Int? = nil,
        category: String = "General",
        streakCount: Int = 0,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.alarmOffsetMinutes = alarmOffsetMinutes
        self.category = category
        self.streakCount = streakCount
        self.notes = notes
    }
}
