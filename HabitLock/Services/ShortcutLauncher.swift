import UIKit

/// [DEPRECATED / FUERA DE ALCANCE]
/// Lanzador heredado del esquema de URLs de la app Atajos (Shortcuts) para fondos de pantalla.
@available(*, deprecated, message: "La integración con atajos para wallpapers está fuera del alcance de HabitLock.")
struct ShortcutLauncher {
    
    /// Ejecuta el atajo nativo especificado pasando la imagen del portapapeles
    static func launchShortcut(named shortcutName: String = AppConstants.defaultShortcutName) {
        let urlString = "\(AppConstants.shortcutsURLScheme)\(shortcutName)&input=clipboard"
        
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            return
        }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("No se pudo abrir la URL del atajo: \(encodedUrlString)")
            }
        }
    }
}
