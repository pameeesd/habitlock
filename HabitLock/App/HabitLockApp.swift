import SwiftUI
import SwiftData

/// Punto de entrada principal de la aplicación HabitLock en iOS 17+.
@main
struct HabitLockApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(persistenceController.sharedModelContainer)
    }
}
