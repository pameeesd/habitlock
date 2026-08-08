# Compilación de Documentación Técnica: HabitLock (Versión 2 - Flujos Detallados)

Este documento unifica las especificaciones técnicas, fragmentos de código nativo, configuraciones del sistema y los **flujos detallados de la experiencia de usuario (UX)** para el desarrollo de **HabitLock**. El propósito principal de la aplicación es la organización eficiente de tareas diarias y semanales con un acceso intuitivo al calendario y un seguimiento interactivo directo desde la pantalla de bloqueo de iOS.

---

## 1. Flujo Técnico Central de Datos e Interacción

Para garantizar que la organización semanal sea el núcleo de la experiencia y que el seguimiento desde la pantalla de bloqueo sea fluido, el sistema se rige por el siguiente ciclo cerrado de datos:

```
+-----------------------------------------------------------------+
|                  1. APLICACIÓN PRINCIPAL (SwiftUI)              |
|  - Creación de tarea rápida en Zona Cálida (Botón "+" o LongPress)|
|  - Vinculación transparente con EventKit (Apple/Google Calendar)|
|  - Guardado en SwiftData (Contenedor compartido App Group)       |
+-------------------------------+---------------------------------+
                                |
                                v (SwiftData Auto-Save)
+-------------------------------+---------------------------------+
|               2. BASE DE DATOS LOCAL COMPARTIDA                 |
|  - SQLite encriptado con FileProtectionType.complete            |
|  - Guardado en el contenedor compartido de App Group            |
+-------------------------------+---------------------------------+
                                |
                                v (WidgetCenter.shared.reloadAllTimelines())
+-------------------------------+---------------------------------+
|           3. PANTALLA DE BLOQUEO (WidgetKit & App Intents)       |
|  - Vista semanal en widgets (Rectangular, Circular, Inline)     |
|  - Marcado directo de tareas con App Intent (ToggleTaskIntent)  |
|  - Solicitud nativa de autenticación biométrica (FaceID/TouchID)|
+-----------------------------------------------------------------+
```

---

## 2. Documentación Detallada de los Flujos de Sistema

### Flujo A: Creación y Vinculación de Tareas desde el Calendario

Este flujo describe la secuencia lógica desde que el usuario registra una tarea en la aplicación principal hasta que se consolida en la base de datos local y compartida:

1.  **Entrada del Usuario:** 
    *   El usuario se encuentra en la vista de Calendario Mensual o Semanal.
    *   Pulsa el botón flotante **"+"** ubicado en la **Zona Cálida Ergonómica** (alcance cómodo con el pulgar) o realiza una **pulsación larga** sobre un día específico para abrir la creación contextual.
2.  **Formulario Simplificado (Sencillez):**
    *   Se despliega una tarjeta modal nativa (`Sheet`) con fondo `.ultraThinMaterial` y tipografía **SF Pro**.
    *   El usuario introduce el título de la tarea (máximo 45 caracteres para evitar truncamientos en widgets).
    *   Selecciona opcionalmente la vinculación al calendario del sistema (Apple/Google Calendar) mediante un interruptor.
    *   Configura una alerta local sutil (ej. "15 minutos antes").
3.  **Persistencia y Sincronización:**
    *   Al pulsar "Guardar", la app solicita permiso de lectura/escritura a través del framework **`EventKit`** si es la primera vez.
    *   La tarea se inserta en el contexto de **`SwiftData`**, el cual está configurado explícitamente para apuntar al directorio compartido del **`App Group`** (`group.com.tuempresa.habitlock`).
    *   Se programa una notificación local de tiempo (`UNCalendarNotificationTrigger`) mediante **`UserNotifications`** de forma 100% offline para preservar la privacidad absoluta.
4.  **Notificación de Actualización:**
    *   Inmediatamente después de guardar, el hilo principal ejecuta `WidgetCenter.shared.reloadAllTimelines()`, indicándole a iOS que refresque los componentes gráficos del Lock Screen de manera inmediata.

---

### Flujo B: Seguimiento e Interactividad Directa desde el Lock Screen (Widgets)

Este flujo detalla cómo el usuario completa tareas directamente en los widgets interactivos del Lock Screen de iOS 17 sin necesidad de desbloquear o navegar dentro de la app:

1.  **Visualización Pasiva:**
    *   El usuario levanta su iPhone. En la pantalla de bloqueo se muestran los widgets de HabitLock (un widget rectangular con la lista de tareas del día de hoy y un widget circular que muestra un anillo con el progreso de completado en verde salvia).
2.  **Interacción Táctil:**
    *   El usuario pulsa el checkbox circular del widget rectangular para marcar una tarea como completada.
3.  **Validación de Seguridad y Privacidad (Responsabilidad):**
    *   iOS detecta la pulsación sobre el control interactivo asociado al `AppIntent` (`ToggleTaskIntent`).
    *   Por motivos de seguridad física de los datos del usuario, iOS retiene temporalmente la ejecución del código en segundo plano y **solicita autenticación biométrica (FaceID o TouchID)** al usuario si el dispositivo está bloqueado.
4.  **Ejecución del Cambió de Estado:**
    *   Una vez autenticado con éxito, se ejecuta el método `perform()` del intent en segundo plano.
    *   El intent accede al contenedor de `SwiftData` compartido, actualiza el campo `isCompleted = true` en la base de datos local SQLite y guarda los cambios de forma segura.
5.  **Retroalimentación Visual (Diseño Emocional):**
    *   El intent llama a `WidgetCenter.shared.reloadAllTimelines()`.
    *   La interfaz del widget se actualiza: la tarea completada se tacha de manera limpia con una línea horizontal sutil, y el texto se atenúa en un tono **verde salvia**. El widget circular incrementa el llenado de su anillo de progreso, ofreciendo un feedback de logro sin generar tensión visual.

---

### Flujo C: Sincronización de Cambios Externos (Sincronización Transparente)

Para asegurar que HabitLock nunca muestre datos inconsistentes si el usuario edita o borra eventos en su aplicación de calendario nativa (Apple Calendar o Google Calendar):

1.  **Escucha en Segundo Plano:**
    *   La aplicación se suscribe al centro de notificaciones del sistema escuchando el evento oficial de Apple: **`.EKEventStoreChanged`**.
2.  **Detección de Cambio:**
    *   El usuario modifica o elimina una reunión de Google Calendar desde otra aplicación.
    *   iOS dispara la notificación de cambio en el sistema.
3.  **Invalidación de Caché:**
    *   HabitLock intercepta la notificación de inmediato (incluso si está suspendida en segundo plano).
    *   La app invalida los datos temporales guardados de esa semana, realiza una nueva consulta estructurada con un predicado (`predicateForEvents`) a `EKEventStore` para el rango de la semana actual y actualiza la base de datos compartida.
4.  **Refresco en Cascada:**
    *   Se invoca el refresco del widget, manteniendo sincronizado el Lock Screen de forma completamente transparente.

---

### Flujo D: Clarificación de Alcance (Exclusión de Fondos de Pantalla / Wallpapers)

> [!IMPORTANT]
> **Aclaración de Alcance de Producto:** La generación de fondos de pantalla (*wallpapers*) vía `ImageRenderer` y la integración con la app Atajos de Apple (*Shortcuts*) fue evaluada previamente pero **NO FORMA PARTE DEL ALCANCE** ni de los requerimientos especificados para HabitLock. 
> 
> El producto se enfoca **exclusivamente en la integración nativa con Widgets de Pantalla de Bloqueo (`WidgetKit`)** mediante contenedores compartidos **App Groups** y SwiftData. La aplicación no genera imágenes de fondo ni requiere la automatización de atajos para la pantalla de bloqueo.

---

## 3. Guía de Código Clave para Desarrollo

### A. Estructura de Persistencia Local Compartida (SwiftData)

Este fragmento define las entidades de base de datos local y su vinculación compartida mediante **App Groups**:

```swift
import Foundation
import SwiftData

@Model
public final class Habit {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var createdAt: Date
    public var markerType: String // "dot", "ring", "square"
    public var hexColor: String   // Ej: "#8FBC8F" (Verde Salvia)
    
    @Relationship(deleteRule: .cascade) public var tasks: [HabitTask]
    
    public init(id: UUID = UUID(), title: String, markerType: String = "dot", hexColor: String = "#8FBC8F") {
        self.id = id
        self.title = title
        self.createdAt = Date()
        self.markerType = markerType
        self.hexColor = hexColor
        self.tasks = []
    }
}

@Model
public final class HabitTask {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var dueDate: Date
    public var isCompleted: Bool
    public var alertMinutesAhead: Int? // 5, 15 o nil
    
    public var habit: Habit?
    
    public init(id: UUID = UUID(), title: String, dueDate: Date, isCompleted: Bool = false, alertMinutesAhead: Int? = nil) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.alertMinutesAhead = alertMinutesAhead
    }
}

// Inicialización del contenedor apuntando al App Group compartido
extension ModelContainer {
    public static var sharedContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitTask.self
        ])
        
        let appGroupIdentifier = "group.com.tuempresa.habitlock"
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            fatalError("No se pudo crear o acceder al App Group compartido.")
        }
        
        let storeURL = sharedContainerURL.appendingPathComponent("HabitLockStore.sqlite")
        let config = ModelConfiguration(url: storeURL)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Error al instanciar el contenedor compartido de SwiftData: \(error.localizedDescription)")
        }
    }()
}
```

### B. Implementación del App Intent Interactivo (`WidgetKit`)

Este es el código que el widget de la pantalla de bloqueo ejecuta en segundo plano cuando el usuario pulsa para tachar una tarea:

```swift
import AppIntents
import WidgetKit
import SwiftData

public struct ToggleTaskIntent: AppIntent {
    public static var title: LocalizedStringResource = "Completar Tarea"
    public static var description = IntentDescription("Marca una tarea como completada o pendiente directamente desde el Lock Screen.")
    
    @Parameter(title: "Task ID")
    public var taskId: UUID
    
    public init() {}
    
    public init(taskId: UUID) {
        self.taskId = taskId
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult {
        let container = ModelContainer.sharedContainer
        let context = container.mainContext
        
        // Consultar la tarea en la base de datos compartida
        let fetchDescriptor = FetchDescriptor<HabitTask>(
            predicate: #Predicate { $0.id == taskId }
        )
        
        if let task = try context.fetch(fetchDescriptor).first {
            // Alternar estado
            task.isCompleted.toggle()
            try context.save()
            
            // Forzar recarga de los widgets del Lock Screen
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        return .result()
    }
}
```

---

*La arquitectura de flujos de HabitLock está diseñada de acuerdo con los Principios de Interfaz Humana de iOS y las Directrices de Seguridad y Privacidad de Apple.*
