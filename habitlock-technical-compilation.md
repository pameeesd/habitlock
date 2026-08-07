# Manual de Implementación Técnica de HabitLock (iOS)

Este documento reúne de manera integral toda la documentación técnica, especificaciones de arquitectura y fragmentos de código necesarios para el desarrollo e implementación de **HabitLock** en iOS. 

El documento sirve como guía definitiva para el equipo de ingeniería para construir una aplicación offline-first, segura, interactiva en la pantalla de bloqueo y con un diseño visual sofisticado.

---

## Índice
1. [Arquitectura General y Compartido de Datos (App Groups)](#1-arquitectura-general-y-compartido-de-datos-app-groups)
2. [Persistencia Local, Privada y Segura (SwiftData & Core Data)](#2-persistencia-local-privada-y-segura-swiftdata--core-data)
3. [Widgets Interactivos en el Lock Screen (WidgetKit & App Intents)](#3-widgets-interactivos-en-el-lock-screen-widgetkit--app-intents)
4. [Generación y Exportación de Fondos de Pantalla (ImageRenderer)](#4-generación-y-exportación-de-fondos-de-pantalla-imagerenderer)
5. [Actualización Semiautomática del Wallpaper (Atajos & URLs)](#5-actualización-semiautomática-del-wallpaper-atajos--urls)
6. [Animación y Transición de Vidrio Esmerilado (SwiftUI)](#6-animación-y-transición-de-vidrio-esmerilado-swiftui)
7. [Integración con EventKit (Calendarios y Recordatorios Nativos)](#7-integración-con-eventkit-calendarios-y-recordatorios-nativos)
8. [Sistema de Alertas y Notificaciones Locales (UserNotifications)](#8-sistema-de-alertas-y-notificaciones-locales-usernotificaciones)

---

## 1. Arquitectura General y Compartido de Datos (App Groups)

Dado que HabitLock interactúa activamente entre la aplicación principal y una extensión de widget en el Lock Screen, es mandatorio compartir la persistencia de datos [14, 56, 61]. Por defecto, iOS aísla a cada extensión en un sandbox privado, haciendo que los datos de la app sean invisibles para el widget y viceversa [61].

### Configuración del App Group en Xcode:
Para habilitar el contenedor de datos compartido [14, 59, 61]:
1. Ve a la configuración del proyecto en Xcode.
2. Selecciona el **App Target principal** -> Pestaña **Signing & Capabilities** [61].
3. Haz clic en `+ Capability` y añade **App Groups** [61].
4. Crea o selecciona un identificador de grupo único (ej: `group.com.empresa.habitlock`) [57, 61].
5. Selecciona el **Extension Target** (el Widget) y repite el proceso, marcando **exactamente el mismo identificador de grupo** [61].

---

## 2. Persistencia Local, Privada y Segura (SwiftData & Core Data)

HabitLock prioriza la privacidad absoluta ("Privacidad Primero") almacenando y procesando toda la agenda localmente en el hardware del dispositivo [17, 47, 50].

### Opción A: Implementación Offline-First Moderna con SwiftData (iOS 17+)
SwiftData simplifica el almacenamiento de datos persistentes utilizando el macro `@Model` y permite sincronizar con CloudKit privado automáticamente cuando hay conexión a Internet [50, 52].

#### 1. Definición del Modelo Compartido
```swift
import Foundation
import SwiftData

@Model 
final class HabitTask {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date
    var alarmOffsetMinutes: Int? // ej. 5 o 15 minutos
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, dueDate: Date, alarmOffsetMinutes: Int? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.alarmOffsetMinutes = alarmOffsetMinutes
    }
}
```

#### 2. Configuración del Contenedor Compartido mediante App Groups
Es mandatorio indicar que el archivo de base de datos se guarde en el contenedor de seguridad del App Group compartido [61]:
```swift
import SwiftUI
import SwiftData

@main
struct HabitLockApp: App {
    // Inicializar el contenedor apuntando a la URL del App Group compartido
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HabitTask.self
        ])
        let appGroupIdentifier = "group.com.empresa.habitlock"
        
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            fatalError("No se pudo crear o acceder al contenedor compartido del App Group.")
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent("HabitLockStore.sqlite")
        let modelConfiguration = ModelConfiguration(url: storeURL)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Error al iniciar el ModelContainer de SwiftData: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer) // Inyecta el contexto en el entorno
    }
}
```

### Opción B: Implementación de Seguridad por Hardware mediante Core Data (iOS 15+)
Si requieres compatibilidad con versiones anteriores o encriptación por hardware a nivel de archivo nativo de base de datos SQLite [47, 49]:

```swift
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init() {
        let appGroupIdentifier = "group.com.empresa.habitlock"
        
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            fatalError("No se pudo acceder al App Group compartido.")
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent("HabitLockCoreData.sqlite")
        container = NSPersistentContainer(name: "HabitLockModel")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        
        // 1. Encriptación por hardware nativo (Máximo nivel de protección local)
        // El archivo se cifra y es completamente inaccesible mientras el dispositivo esté bloqueado
        description.setOption(
            FileProtectionType.complete as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
        
        // 2. Rastreo de historial persistente (Requerido para que la app principal detecte cambios realizados por el widget)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSStoreModelVersionIdentifiersKey)
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Fallo al cargar el stack de Core Data: \(error)")
            }
        }
    }
}
```

---

## 3. Widgets Interactivos en el Lock Screen (WidgetKit & App Intents)

Desde iOS 17, se pueden crear widgets en la pantalla de bloqueo capaces de ejecutar lógica de negocio y actualizar la base de datos de manera inmediata utilizando botones o conmutadores interactivos [12, 56].

### Paso 1: Crear el App Intent para marcar tareas
```swift
import AppIntents
import WidgetKit
import SwiftData

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Completar Tarea"
    
    // Parámetro para recibir el ID único de la tarea a tachar
    @Parameter(title: "ID de Tarea")
    var taskId: UUID
    
    init() {}
    
    init(taskId: UUID) {
        self.taskId = taskId
    }
    
    func perform() async throws -> some IntentResult {
        let appGroupIdentifier = "group.com.empresa.habitlock"
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return .result()
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent("HabitLockStore.sqlite")
        let config = ModelConfiguration(url: storeURL)
        
        // Crear un contexto manual de SwiftData para operaciones en segundo plano
        let container = try ModelContainer(for: Schema([HabitTask.self]), configurations: [config])
        let context = ModelContext(container)
        
        // Consultar la tarea por su ID único
        let fetchDescriptor = FetchDescriptor<HabitTask>()
        if let allTasks = try? context.fetch(fetchDescriptor) {
            if let taskToUpdate = allTasks.first(where: { $0.id == taskId }) {
                taskToUpdate.isCompleted.toggle()
                try? context.save()
            }
        }
        
        // Forzar a iOS a recargar todos los widgets de la app en el Lock Screen
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
```

### Paso 2: Diseño de la Vista del Widget
```swift
import SwiftUI
import WidgetKit

struct LockScreenWidgetView: View {
    var entry: SimpleEntry // Proporcionado por el TimelineProvider
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 4) {
                Text("Agenda de Hoy")
                    .font(.caption2)
                    .bold()
                
                ForEach(entry.tasks.prefix(2)) { task in
                    HStack {
                        // El botón interactivo de iOS 17 que dispara el App Intent en segundo plano
                        Button(intent: ToggleTaskIntent(taskId: task.id)) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain) // Evita decoraciones de botón por defecto
                        
                        Text(task.title)
                            .font(.system(size: 11))
                            .lineLimit(1)
                    }
                }
            }
            // Los widgets del Lock Screen eliminan colores brillantes para garantizar la lectura sobre el fondo
            .widgetAccentable() 
        default:
            Text("No soportado")
        }
    }
}
```

### Nota Crítica sobre Seguridad en la Pantalla de Bloqueo:
Por motivos de privacidad de datos personales, si el iPhone se encuentra bloqueado, los controles interactivos permanecerán inactivos hasta que el usuario se autentique de forma biométrica (Face ID / Touch ID) o introduzca su código [56]. iOS requerirá de forma mandatoria este desbloqueo antes de ejecutar el método `perform()` del App Intent [56].

---

## 4. Generación y Exportación de Fondos de Pantalla (ImageRenderer)

Para integrar la planificación diaria en el fondo de pantalla de bloqueo, HabitLock debe renderizar una vista de SwiftUI como una imagen física en la galería del usuario [15, 53].

### 1. Claves de Privacidad obligatorias (`Info.plist`):
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>HabitLock requiere acceso para guardar los fondos de pantalla personalizados generados por tu agenda en la galería de fotos.</string>
```

### 2. Implementación de Captura de Pantalla
```swift
import SwiftUI
import Photos

@MainActor
class WallpaperGenerator: ObservableObject {
    
    // El renderizado de vistas complejas debe ejecutarse en el MainActor
    func generateAndSaveWallpaper(tasks: [HabitTask]) {
        // 1. Instanciar la vista SwiftUI con la relación de aspecto vertical ideal (9:16)
        let templateView = WallpaperDesignView(tasks: tasks)
            .frame(width: 1125, height: 2436) // Resolución nítida para pantallas Retina
        
        // 2. Utilizar el ImageRenderer nativo de iOS 16+
        let renderer = ImageRenderer(content: templateView)
        renderer.scale = 3.0 // Forzar calidad máxima
        
        guard let uiImage = renderer.uiImage else {
            print("Error al renderizar la vista de SwiftUI.")
            return;
        }
        
        // 3. Guardar en el carrete mediante Photos Framework de forma segura
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if status == .authorized || status == .limited {
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                } completionHandler: { success, error in
                    if success {
                        print("Fondo de pantalla guardado exitosamente en la fototeca.")
                        // Proceder a copiar al portapapeles y activar redirección
                        DispatchQueue.main.async {
                            UIPasteboard.general.image = uiImage
                        }
                    } else if let error = error {
                        print("Error al guardar la imagen: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
```

---

## 5. Actualización Semiautomática del Wallpaper (Atajos & URLs)

Apple **no proporciona una API pública** para cambiar el fondo de pantalla de bloqueo de manera silenciosa y programática desde una aplicación de terceros para evitar modificaciones de sistema no autorizadas [1].

### Flujo de Trabajo Homologado (Solución por Atajos):
Para implementar una experiencia fluida, HabitLock aprovecha la acción de sistema **"Establecer foto de fondo de pantalla"** introducida en Atajos desde iOS 16.2 [1].

```
[ App principal: Genera Imagen ]
              │
              ▼
[ Copia automáticamente al portapapeles (UIPasteboard) ]
              │
              ▼
[ Abre URL de Atajos: shortcuts://run-shortcut?name=AtajoHabitLock&input=clipboard ]
              │
              ▼
[ Atajo de iOS procesa el Portapapeles y configura el Lock Screen de inmediato ]
```

#### Código Swift para automatizar la ejecución del Atajo:
```swift
import UIKit

func applyWallpaperWithShortcut() {
    // 1. El nombre del atajo debe coincidir exactamente con el configurado por el usuario
    let shortcutName = "AtajoHabitLock"
    
    // 2. Construir la URL utilizando el esquema shortcuts:// con el portapapeles como entrada
    let urlString = "shortcuts://run-shortcut?name=\(shortcutName)&input=clipboard"
    
    guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: encodedUrlString) else {
        return
    }
    
    // 3. Abrir el enlace del sistema para ejecutar la automatización al instante
    DispatchQueue.main.async {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
```

#### Guía para el usuario final:
Dentro de la app, el usuario debe crear manualmente un atajo de un solo bloque en la aplicación nativa **Atajos**:
*   *Acción:* **"Establecer foto de fondo de pantalla"** -> Configurar para recibir la entrada desde el **Portapapeles** y aplicarla a la Pantalla de Bloqueo.

---

## 6. Animación y Transición de Vidrio Esmerilado (SwiftUI)

Para implementar el efecto de "zoom" centrado sobre un día de la semana sin romper la sobriedad visual de la aplicación, se utiliza un contenedor translúcido mediante una transición espacial fluida y elástica [43, 45].

```swift
import SwiftUI

struct CustomGlassmorphicContainerView: View {
    @State private var isZoomed: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo fotográfico de la pantalla de bloqueo
            Image("UserWallpaper")
                .resizable()
                .scaledToFill()
                .blur(radius: isZoomed ? 12 : 0) // Aplica desenfoque dinámico al fondo
                .animation(.easeInOut(duration: 0.3), value: isZoomed)
            
            // Botón interactivo semanal (simulado)
            VStack {
                Button("Zoom Lunes") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isZoomed.toggle()
                    }
                }
                .padding()
            }
            
            // 2. El contenedor cuadrado de zoom con efecto esmerilado
            if isZoomed {
                VStack(alignment: .leading, spacing: 12) {
                    // TÍTULO: Estilo SF Pro Semibold con exactamente +2pt de escala respecto a las tareas
                    Text("Lunes 10")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.init(red: 0.1, green: 0.25, blue: 0.15)) // Verde Pino
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    // CONTENIDO: SF Pro Regular a 14 pt (Sin ruido visual)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.init(red: 0.55, green: 0.72, blue: 0.62)) // Verde Salvia
                            Text("Meditación matutina")
                                .font(.system(size: 14, weight: .regular))
                                .strikethrough() // Tachable
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.init(red: 0.1, green: 0.25, blue: 0.15))
                            Text("Beber 2L de agua")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.init(red: 0.1, green: 0.25, blue: 0.15))
                        }
                    }
                }
                .padding(20)
                .frame(width: 280, height: 280) // Contenedor cuadrado compacto
                // 3. Estilo Frost de alta fidelidad nativo
                .background(.ultraThinMaterial) 
                .cornerRadius(24)
                // Borde fino lineal blanco para el reflejo del vidrio
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.35), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                // 4. Transición combinada de escala suave y fade
                .transition(.scale(scale: 0.95).combined(with: .opacity)) 
            }
        }
    }
}
```

---

## 7. Integración con EventKit (Calendarios y Recordatorios Nativos)

Para que HabitLock lea y mantenga sincronizada la agenda semanal de Google Calendar o Apple Calendar en el Lock Screen [16, 21]:

### 1. Permisos en el archivo `Info.plist` (Requerido para iOS 17+):
```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>HabitLock requiere acceso completo a tus calendarios para listar y mostrar tu agenda semanal directamente en el fondo de pantalla de bloqueo.</string>
<key>NSRemindersFullAccessUsageDescription</key>
<string>HabitLock requiere acceso completo a tus recordatorios para permitirte ver y tachar tus tareas pendientes del día.</string>
```

### 2. Implementación del Sincronizador de Calendarios
```swift
import EventKit
import Combine

class CalendarManager: ObservableObject {
    let eventStore = EKEventStore()
    @Published var currentWeekEvents: [EKEvent] = []
    
    init() {
        requestAccessAndFetch()
        setupChangeObserver()
    }
    
    // Solicitar permiso de acceso de lectura y escritura
    func requestAccessAndFetch() {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                if granted {
                    self?.fetchCurrentWeekEvents()
                }
            }
        } else {
            // Soporte para iOS 16 y versiones previas
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                if granted {
                    self?.fetchCurrentWeekEvents()
                }
            }
        }
    }
    
    // Consulta eficiente para el rango de la semana en curso
    func fetchCurrentWeekEvents() {
        let calendar = Calendar.current
        let now = Date()
        
        // Calcular el inicio (Lunes 00:00) y fin (Domingo 23:59) de la semana en curso
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) else {
            return
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfWeek, end: endOfWeek, calendars: nil)
        
        DispatchQueue.main.async {
            self.currentWeekEvents = self.eventStore.events(matching: predicate)
            print("Eventos cargados para la semana actual: \(self.currentWeekEvents.count)")
        }
    }
    
    // Suscripción automática a modificaciones de calendario de fuentes externas
    private func setupChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChanged(_:)),
            name: .EKEventStoreChanged,
            object: eventStore
        )
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        // Los datos del sistema han cambiado en segundo plano; refrescar caché local
        fetchCurrentWeekEvents()
    }
}
```

---

## 8. Sistema de Alertas y Notificaciones Locales (UserNotifications)

Para programar alertas locales de tareas que permitan al usuario hacer tap y saltar directo a su agenda sin usar servidores o conexiones a internet, se utiliza `UNCalendarNotificationTrigger` [18].

```swift
import UserNotifications

class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    
    // Solicitar permisos de notificación en el primer arranque
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permiso de notificaciones locales concedido.")
            }
        }
    }
    
    // Programar un recordatorio basado en la hora específica de una tarea
    func scheduleTaskReminder(task: HabitTask) {
        let center = UNUserNotificationCenter.current()
        
        // 1. Configurar el contenido del mensaje
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio de Tarea"
        content.body = "Es hora de completar: \(task.title)"
        content.sound = .default
        
        // Asociar la información de la app para abrir la vista correspondiente
        content.userInfo = ["taskId": task.id.uuidString]
        
        // 2. Calcular los componentes del calendario restando el offset (ej. 5 o 15 minutos antes)
        let calendar = Calendar.current
        var notificationDate = task.dueDate
        
        if let offset = task.alarmOffsetMinutes {
            notificationDate = calendar.date(byAdding: .minute, value: -offset, to: task.dueDate) ?? task.dueDate
        }
        
        // Extraer únicamente hora, minutos, día, mes y año para el disparador
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        
        // 3. Crear el disparador basado en calendario
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // 4. Instanciar y agendar la petición
        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error al programar recordatorio local: \(error.localizedDescription)")
            } else {
                print("Notificación local agendada con éxito para la tarea: \(task.title)")
            }
        }
    }
    
    // Cancelar recordatorios agendados de tareas editadas o eliminadas
    func cancelReminder(for task: HabitTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
```

---
*Este manual técnico provee el estándar de desarrollo para la implementación del ecosistema de HabitLock, asegurando la máxima sintonía con las directrices de interfaz humana y el sistema operativo de Apple.*
