import SwiftUI

/// Vista contenedora principal con barra de pestañas (TabView) para la app HabitLock.
struct ContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.creamWhite)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            MainAgendaView()
                .tabItem {
                    Label("Agenda", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
        }
        .tint(.sageGreen)
    }
}
