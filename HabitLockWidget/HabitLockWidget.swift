import WidgetKit
import SwiftUI
import SwiftData

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [HabitTask]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), tasks: [
            HabitTask(title: "Meditación matutina", isCompleted: false),
            HabitTask(title: "Beber 2L de agua", isCompleted: true)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), tasks: fetchTasks())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = SimpleEntry(date: Date(), tasks: fetchTasks())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchTasks() -> [HabitTask] {
        guard let sharedContainerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: AppConstants.appGroupIdentifier
        ) else {
            return []
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent(AppConstants.databaseFilename)
        let config = ModelConfiguration(url: storeURL)
        
        do {
            let container = try ModelContainer(for: Schema([HabitTask.self]), configurations: [config])
            let context = ModelContext(container)
            var fetchDescriptor = FetchDescriptor<HabitTask>(
                sortBy: [SortDescriptor(\.dueDate, order: .forward)]
            )
            fetchDescriptor.fetchLimit = 3
            return (try? context.fetch(fetchDescriptor)) ?? []
        } catch {
            return []
        }
    }
}

@main
struct HabitLockWidget: Widget {
    let kind: String = "HabitLockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("HabitLock Agenda")
        .description("Visualiza y tacha tus hábitos diarios directamente desde la pantalla de bloqueo.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .systemSmall])
    }
}
