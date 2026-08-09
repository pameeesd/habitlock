import SwiftUI
import SwiftData

/// Punto de entrada principal de la aplicación HabitLock en iOS 17+.
@main
struct HabitLockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(ModelContainer.sharedContainer)
    }
}
