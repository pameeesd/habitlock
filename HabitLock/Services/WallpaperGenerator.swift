import SwiftUI
import Photos
import UIKit

/// [DEPRECATED / FUERA DE ALCANCE]
/// Servicio heredado para exportación de fondos de pantalla.
/// La generación de fondos de pantalla/wallpapers fue excluida del alcance de HabitLock en favor de Widgets nativos de WidgetKit.
@available(*, deprecated, message: "La generación de wallpapers está fuera del alcance oficial de HabitLock.")
@MainActor
class WallpaperGenerator: ObservableObject {
    @Published var isGenerating: Bool = false
    @Published var lastGeneratedImage: UIImage? = nil
    
    /// Renderiza la vista de agenda en resolución vertical (1125x2436 pt), la guarda en Fotos y copia al portapapeles.
    func generateAndSaveWallpaper(tasks: [HabitTask], completion: @escaping (Bool) -> Void) {
        isGenerating = true
        
        // 1. Instanciar la plantilla visual de 9:16
        let templateView = WallpaperDesignView(tasks: tasks)
            .frame(width: 1125, height: 2436)
        
        // 2. Renderizar con escala nativa Retina
        let renderer = ImageRenderer(content: templateView)
        renderer.scale = 3.0
        
        guard let uiImage = renderer.uiImage else {
            self.isGenerating = false
            completion(false)
            return
        }
        
        self.lastGeneratedImage = uiImage
        
        // 3. Guardar en la fototeca de Fotos
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                } completionHandler: { success, error in
                    DispatchQueue.main.async {
                        self.isGenerating = false
                        if success {
                            // Copiar la imagen al portapapeles del sistema
                            UIPasteboard.general.image = uiImage
                            completion(true)
                        } else {
                            print("Error al guardar imagen en fototeca: \(error?.localizedDescription ?? "desconocido")")
                            completion(false)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isGenerating = false
                    completion(false)
                }
            }
        }
    }
}
