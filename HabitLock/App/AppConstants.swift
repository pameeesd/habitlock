import Foundation

/// Constantes globales para la configuración del contenedor de seguridad y sincronizaciones.
struct AppConstants {
    /// Identificador del App Group registrado en Apple Developer y Xcode.
    static let appGroupIdentifier = "group.com.empresa.habitlock"
    
    /// Nombre del archivo SQLite compartido entre App y Widget.
    static let databaseFilename = "HabitLockStore.sqlite"
    
    /// Nombre predeterminado del Atajo de iOS para la regeneración del Wallpaper.
    static let defaultShortcutName = "HabitLockWallpaper"
    
    /// Esquema de URL para lanzar la ejecución de Atajos nativos.
    static let shortcutsURLScheme = "shortcuts://run-shortcut?name="
}
