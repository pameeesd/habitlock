import Foundation
import SwiftData

/// Modelo de entidad persistente para tareas con SwiftData (iOS 17+).
@Model
public final class HabitTask {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var dueDate: Date
    public var isCompleted: Bool
    public var alarmOffsetMinutes: Int? // 5, 15 o nil
    public var alertMinutesAhead: Int? {
        get { alarmOffsetMinutes }
        set { alarmOffsetMinutes = newValue }
    }
    public var category: String
    public var streakCount: Int
    public var notes: String?
    
    public var habit: Habit?
    
    public init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date = Date(),
        isCompleted: Bool = false,
        alarmOffsetMinutes: Int? = nil,
        category: String = "General",
        streakCount: Int = 0,
        notes: String? = nil,
        habit: Habit? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.alarmOffsetMinutes = alarmOffsetMinutes
        self.category = category
        self.streakCount = streakCount
        self.notes = notes
        self.habit = habit
    }
}
