import SwiftUI

/// Estilos tipográficos SF Pro acordes al Blueprint de diseño de HabitLock.
/// Evita la contaminación visual limitando el título del día a máximo +2pt respecto a las tareas.
struct HabitLockTypography {
    /// Título de Día Seleccionado / Zoom (SF Pro Display Semibold a 16pt)
    static let zoomTitle = Font.system(size: 16, weight: .semibold, design: .default)
    
    /// Cuerpo de Tarea o Hábito (SF Pro Text Regular a 14pt)
    static let taskBody = Font.system(size: 14, weight: .regular, design: .default)
    
    /// Etiquetas Secundarias u Horarios (SF Pro Text Regular a 12pt)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    
    /// Título de Sección o Encabezado de Vista (SF Pro Semibold a 20pt)
    static let sectionHeader = Font.system(size: 20, weight: .bold, design: .default)
}
