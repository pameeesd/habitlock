import SwiftUI

/// Vista contenedora principal con barra de pestañas (TabView) para la app HabitLock.
struct ContentView: View {
    var body: some View {
        TabView {
            MainAgendaView()
                .tabItem {
                    Label("Agenda", systemName: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemName: "gearshape")
                }
        }
        .tint(.sageGreen)
    }
}
