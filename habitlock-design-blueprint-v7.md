# Especificación Técnica y de Diseño de UX/UI: HabitLock (Versión 7 - Consolidada)

Este documento técnico y de diseño unifica las directrices de interfaz humana de iOS, los principios de diseño de Apple y el mapa de APIs de desarrollo de iOS para **HabitLock**. El sistema está diseñado para integrar la planificación de la agenda y la consolidación de hábitos saludables directamente desde la pantalla de bloqueo y dentro de la aplicación principal.

---

## 1. Filosofía de Diseño y Objetivos Principales

*   **Objetivo Claro (Crea valor):** El propósito principal de HabitLock es ayudar a las personas a gestionar su tiempo y construir hábitos saludables de manera eficiente [15, 31]. Se enfoca exclusivamente en estas dos funciones, perfeccionándolas sin añadir características innecesarias [15, 31].
*   **Diseño Emocional (Deleite sin ansiedad):** Como aplicación de desarrollo personal, la estética visual de HabitLock inspira relajación, constancia y motivación, guiando al usuario de forma calmada a través de un diseño limpio que evita la sobredecoración [10, 30, 40, 41].
*   **Interacciones Breves y Eficientes:** Diseñado para las ráfagas habituales de uso en iOS (sesiones rápidas de 1 a 2 minutos para consultar actualizaciones o registrar datos mientras se desplazan) [6], así como para consultas instantáneas de fracciones de segundo desde la pantalla de bloqueo [15].

---

## 2. Paleta de Colores Unificada (Enfoque de Calma Orgánica)

Para eliminar el ruido visual y consolidar una experiencia que inspire relajación [10, 40], se descartan los colores contrastantes dispersos. Se adopta una **paleta análoga basada en tonos verdes orgánicos y neutros suaves**, que mantiene la armonía cromática tanto en la app como en los elementos superpuestos del Lock Screen:

*   **Verde Salvia (Verde Principal - Éxito y Progreso):** Utilizado para el rastreador de hábitos, marcar tareas como "listas" (tachar) e indicadores de racha [10]. Es el tono de acento principal que evoca crecimiento y tranquilidad activa.
*   **Verde Bosque / Pino (Verde Oscuro - Estructura y Texto):** Tono de alto contraste que sustituye al negro puro para textos principales, títulos elegantes de calendario y bordes de elementos activos. Aporta legibilidad excepcional y seriedad sin tensión visual [38].
*   **Verde Eucalipto / Menta Atenuado (Acento Secundario):** Utilizado para el marcador del día "Hoy" (anillo, punto o cuadrado) y para destacar bloques de tiempo específicos en la agenda sin generar estridencias ni competir con el verde salvia [16, 35].
*   **Crema / Blanco Hueso (Fondo Claro):** Suaviza la interfaz en modo claro, ofreciendo un lienzo natural que reduce la fatiga visual en comparación con el blanco puro de pantalla [8, 36].
*   **Verde Musgo Profundo / Carbón (Fondo Oscuro):** Base de soporte para el Modo Oscuro y para el contenedor cuadrado de zoom, manteniendo la consistencia cromática orgánica incluso de noche [8, 36].

---

## 3. Mapa Ergonómico de la Pantalla del iPhone

De acuerdo con las pautas de ergonomía de iOS, las personas sostienen habitualmente el iPhone con una o dos manos mientras se desplazan [5]. Por ello, HabitLock distribuye sus elementos basándose en las **zonas de alcance ergonómico** [8]:

```
+-----------------------------------+
|  [ Zona Fría / Difícil Alcance ]  | -> Título de Pantalla, Indicador de Mes.
|                                   |    (Solo información visual estática).
+-----------------------------------+
|  [ Zona Templada / Alcance Medio] | -> Visualizador de Calendario y Hábitos.
|                                   |    Área de lectura principal.
+-----------------------------------+
|  [ Zona Cálida / Fácil Alcance ]  | -> Botón de Acción Principal (+), 
|                                   |    Completado de hábitos, Tarjeta de Zoom.
|  (Fácil control con el pulgar)     |    Gestos de deslizar para acciones.
+-----------------------------------+
```

*   **Zona Inferior y Central (Fácil acceso):** Colocamos aquí los botones interactivos clave (como el botón para añadir eventos/hábitos y los botones de check-in rápido de hábitos) para que puedan pulsarse cómodamente con el pulgar [8].
*   **Gestos Naturales:** Implementación de gestos de deslizamiento (swipe) hacia la izquierda en elementos de listas para revelar acciones rápidas (editar, eliminar) y deslizamiento lateral para navegar o retroceder entre vistas [8].

---

## 4. Estructura de Pantallas y Mecánica de "Zoom" Coherente

### Pantalla de Bloqueo (Lock Screen - Vista Semanal Panorámica)
*   **Fondo de Pantalla Regenerado:** Muestra la foto del usuario con un filtro de atenuación ajustable [15, 16].
*   **Diseño Semanal:** Una fila minimalista y horizontal que presenta los días de la semana de forma compacta y legible [15].

### El Flujo de "Zoom" Coherente (Contenedor Cuadrado Centrado)
Para evitar que el diseño de zoom se rompa o se sienta inconexo respecto a la vista de los días de la semana, se implementan las siguientes directrices de integración visual [35, 36]:

1.  **Contenedor Compacto de Tamaño Moderado:** En lugar de desplegar una tarjeta modal gigante que cubra la pantalla completa, el zoom activa un **contenedor cuadrado con efecto de vidrio esmerilado translúcido (*glassmorphic*) perfectamente centrado**. Esto permite que el usuario siga viendo la estructura de los días de la semana atenuada en la periferia de la pantalla, manteniendo el contexto espacial sin romper el diseño global del fondo [36, 43, 45].
2.  **Escala Tipográfica Estricta (SF Pro):** Se adopta la tipografía nativa de Apple, **San Francisco (SF Pro)** [5]. Para evitar el ruido visual, el título del día seleccionado utiliza un tamaño máximo de **2 puntos (pt) más grande** que las tareas [38]:
    *   *Título del Día (ej. "Lunes 10"):* SF Pro Display (Semibold) a 16 pt [5].
    *   *Cuerpo de Tareas:* SF Pro Text (Regular) a 14 pt [5].
3.  **Transición de Desenfoque y Enfoque:** Al activarse el zoom sobre un día, los otros días de la semana de la sección superior se atenúan ligeramente en opacidad (50%), mientras que el fondo fotográfico se difumina suavemente mediante un efecto de desenfoque progresivo (*blur*) detrás del contenedor [36, 43, 45].
4.  **Lista de Tareas Tacheables:**
    *   Las tareas pendientes se muestran con un sutil checkbox circular en **Verde Bosque** [35].
    *   Al marcar una tarea, se tacha de manera limpia con una sutil línea horizontal y el texto pasa a un tono **Verde Salvia** atenuado, comunicando logro y bienestar sin estridencias de color [10, 30].

---

## 5. Arquitectura Técnica y Mapeo de APIs de iOS

La siguiente tabla resume cómo se asocia cada función de la aplicación con las tecnologías e implementaciones técnicas nativas de Apple:

| Característica / Función de HabitLock | API / Framework de iOS principal | Detalles Técnicos de Implementación |
| :--- | :--- | :--- |
| **Sincronización de Calendario y Recordatorios** | `EventKit` [21] | - Solicita autorizaciones `NSCalendarsFullAccessUsageDescription` y `NSRemindersFullAccessUsageDescription` [21].<br>- Calcula rangos de fechas mediante `Calendar.current` y recupera eventos con `predicateForEvents(withStart:end:calendars:)` [22].<br>- Escucha el evento `.EKEventStoreChanged` mediante `NotificationCenter` para detectar cambios externos del usuario y actualizar la vista [22, 23]. |
| **Notificaciones Locales (Avisos Previos)** | `UserNotifications` [18] | - Solicita permisos con `UNUserNotificationCenter.current().requestAuthorization` [18, 19].<br>- Programa alertas de 5 o 15 minutos antes usando `UNCalendarNotificationTrigger` con componentes de fecha parciales (`DateComponents` con hora, minuto o día de la semana) [16, 18, 19, 20].<br>- Todo se ejecuta de forma 100% local en el procesador del iPhone sin depender de servidores push externos, garantizando privacidad [17, 18]. |
| **Persistencia Local, Privada y Segura** | `SwiftData` [50] & `Core Data` [47] | - **Enfoque Offline-First:** Define entidades con el macro `@Model` en SwiftData [50].<br>- **Seguridad por Hardware:** Configura el almacén de base de datos con `FileProtectionType.complete` en el persistent store coordinator de Core Data [47, 48]. Esto cifra la base de datos local SQLite y la hace inaccesible mientras el dispositivo está bloqueado [47, 49].<br>- Los secretos y contraseñas sensibles se almacenan exclusivamente en el iOS Keychain, nunca en texto plano [49]. |
| **Acceso Compartido (App y Widgets de Pantalla de Bloqueo)** | `App Groups` [57, 61] | - El widget interactivo y la aplicación principal se registran bajo el mismo identificador de grupo (ej. `group.com.empresa.habitlock`) [57, 61].<br>- Configura la base de datos compartida apuntando al contenedor común: `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)` [57, 61].<br>- En Core Data, se habilita `NSPersistentHistoryTrackingKey` para que la aplicación principal detecte automáticamente las tareas completadas por el usuario desde el widget de la pantalla de bloqueo [59]. |
| **Interactividad en el Lock Screen (Tachar Tareas)** | `WidgetKit` & `App Intents` [12, 56] | - Permite crear botones interactivos directamente en el Lock Screen usando `Button(intent:)` vinculados a un `AppIntent` [12, 13, 56].<br>- El método `perform()` del intent actualiza el estado de la tarea en la base de datos compartida y refresca el widget invocando `WidgetCenter.shared.reloadAllTimelines()` [56, 63].<br>- *Restricción de Seguridad:* Si el iPhone está bloqueado, iOS forzará la autenticación biométrica o código antes de ejecutar la acción del intent para mantener la privacidad de los datos [56]. |
| **Generación Dinámica del Fondo de Pantalla** | `SwiftUI` & `ImageRenderer` [53, 54] | - Convierte las vistas SwiftUI que contienen la agenda y el calendario semanal en imágenes estáticas de alta resolución (ej. 1125 x 2436 pt) en el hilo principal (`@MainActor`) utilizando `ImageRenderer` [54, 55].<br>- Guarda la imagen en la galería del usuario usando el framework `Photos` (`PHPhotoLibrary`), requiriendo el permiso `Privacy - Photo Library Additions Usage Description` en el `Info.plist` [53, 54]. |
| **Enlace de Actualización Semiautomática** | `UIKit` & `Shortcuts app` [1, 2] | - Dado que iOS no permite cambiar el fondo de pantalla en segundo plano de forma silenciosa por motivos de seguridad (*sandboxing*), la app copia la imagen generada al portapapeles: `UIPasteboard.general.image = image` [1, 2].<br>- Lanza el esquema de URL nativo de Apple Atajos: `shortcuts://run-shortcut?name=NombreDelAtajo&input=clipboard` para guiar al usuario a ejecutar el comando nativo "Set Wallpaper Photo" con un solo toque [1, 11]. |
| **Animación de Vidrio Esmerilado (Glassmorphism)** | `SwiftUI` [43, 45] | - El contenedor cuadrado de zoom flotante se implementa en un `ZStack` usando `.background(.ultraThinMaterial)` para simular el vidrio frosted sobre el fondo fotográfico desenfocado [43, 45].<br>- Se añade un borde sutil con un degradado lineal blanco de baja opacidad y una sombra suave para aportar sensación de elevación [43, 45].<br>- El contenedor aparece mediante una transición elástica sumamente fluida: `withAnimation(.spring(response: 0.4, dampingFraction: 0.8))` combinando efectos de escala y opacidad para preservar el contexto espacial del usuario de manera natural [43, 45]. |

---

## 6. Siguiente Paso del Desarrollo: Consideraciones Técnicas Clave

1.  **Comportamiento de AppIntent en Bloqueo:** Para cambiar el fondo de pantalla tras tachar una tarea desde el widget de la pantalla de bloqueo, el `AppIntent` asociado debe abrir la app principal estableciendo la propiedad `openAppWhenRun = true`. Esto se debe a que iOS no permite invocar el esquema de URLs `shortcuts://` o actualizar el portapapeles del sistema mientras el dispositivo se encuentra bloqueado y la app está en segundo plano absoluto.
2.  **Sincronización Directa de Google Calendar:** Si en el futuro se desea evadir el uso de las cuentas nativas configuradas en el iPhone (que `EventKit` lee de forma automática [21]), se deberá integrar el SDK de Google Sign-In para iOS y consumir directamente la Google Calendar REST API mediante peticiones de red cifradas de extremo a extremo, aunque la recomendación por simplicidad y privacidad es delegar esta sincronización en la base de datos de calendarios nativa del sistema [21].

---
*Especificación conceptual y de arquitectura técnica construida estrictamente bajo las directrices de interfaz humana de iOS, los principios de diseño de Apple y el framework de APIs oficial.* [4, 9, 24]
