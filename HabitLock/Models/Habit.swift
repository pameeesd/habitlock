import Foundation
import SwiftData

/// Modelo persistente que representa un hábito o categoría principal con SwiftData (iOS 17+).
@Model
public final class Habit {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var createdAt: Date
    public var markerType: String // "dot", "ring", "square"
    public var hexColor: String   // Ej: "#8FBC8F" (Verde Salvia)
    
    @Relationship(deleteRule: .cascade) public var tasks: [HabitTask]
    
    public init(
        id: UUID = UUID(),
        title: String,
        markerType: String = "dot",
        hexColor: String = "#8FBC8F"
    ) {
        self.id = id
        self.title = title
        self.createdAt = Date()
        self.markerType = markerType
        self.hexColor = hexColor
        self.tasks = []
    }
}
