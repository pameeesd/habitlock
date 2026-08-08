import Foundation
import SwiftData

/// Extension para inicializar el contenedor compartido de SwiftData apuntando al App Group.
extension ModelContainer {
    public static var sharedContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitTask.self
        ])
        
        let appGroupIdentifier = AppConstants.appGroupIdentifier
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            fatalError("No se pudo crear o acceder al App Group compartido: \(appGroupIdentifier)")
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent(AppConstants.databaseFilename)
        let config = ModelConfiguration(url: storeURL)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Error al instanciar el contenedor compartido de SwiftData: \(error.localizedDescription)")
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
