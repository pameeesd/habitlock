import Foundation
import SwiftData
import CoreData

/// Controlador de persistencia compartido para App y Extensiones de Widget.
/// Configura el contenedor seguro del App Group y habilita cifrado por hardware en SQLite.
class PersistenceController {
    static let shared = PersistenceController()
    
    /// Contenedor de SwiftData para iOS 17+
    let sharedModelContainer: ModelContainer
    
    private init() {
        let schema = Schema([
            HabitTask.self
        ])
        
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
        ) else {
            fatalError("No se pudo acceder al contenedor compartido del App Group: \(AppConstants.appGroupIdentifier)")
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent(AppConstants.databaseFilename)
        let modelConfiguration = ModelConfiguration(url: storeURL)
        
        do {
            self.sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Error al inicializar el ModelContainer de SwiftData: \(error)")
        }
    }
}
