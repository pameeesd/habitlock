import Foundation
import SwiftData

/// Extension para inicializar el contenedor compartido de SwiftData apuntando al App Group con fallback local seguro.
extension ModelContainer {
    public static var sharedContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitTask.self
        ])
        
        let appGroupIdentifier = AppConstants.appGroupIdentifier
        
        // 1. Intentar usar el App Group compartido si está disponible
        if let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            print("[Persistence] App Group disponible: \(sharedContainerURL.path)")
            let storeURL = sharedContainerURL.appendingPathComponent(AppConstants.databaseFilename)
            let config = ModelConfiguration(url: storeURL)
            
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                print("[Persistence] Error al abrir store compartido: \(error.localizedDescription)")
                print("[Persistence] Usando store local de fallback.")
            }
        } else {
            print("[Persistence] App Group no disponible (\(appGroupIdentifier)). Usando almacenamiento local.")
        }
        
        // 2. Fallback a almacenamiento local dentro del sandbox de la app / extensión
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let localStoreURL = appSupportURL.appendingPathComponent(AppConstants.databaseFilename)
            let localConfig = ModelConfiguration(url: localStoreURL)
            
            return try ModelContainer(for: schema, configurations: [localConfig])
        } catch {
            print("[Persistence] Error al crear contenedor local de fallback: \(error.localizedDescription)")
            fatalError("Error crítico al instanciar el contenedor de SwiftData (compartido y local): \(error.localizedDescription)")
        }
    }()
}

/// Controlador de persistencia compartido para compatibilidad y acceso global.
class PersistenceController {
    static let shared = PersistenceController()
    
    let sharedModelContainer: ModelContainer
    
    private init() {
        self.sharedModelContainer = ModelContainer.sharedContainer
    }
}

