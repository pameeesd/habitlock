# HabitLock - App para iOS (SwiftUI & SwiftData)

**HabitLock** es una aplicación para iOS diseñada para integrar la planificación de la agenda y la consolidación de hábitos saludables directamente en la Pantalla de Bloqueo (Lock Screen) del iPhone.

---

## 🌿 Características Principales

1. **Diseño de Calma Orgánica:** Paleta armónica basada en Verde Salvia, Verde Bosque/Pino, Crema y Verde Eucalipto para evitar la fatiga visual.
2. **Ergonomía Adaptada a iOS:** Zonas de alcance distribuidas para interacción cómoda con una sola mano (pulgar) y gestos de deslizamiento.
3. **Privacidad Offline-First:** Los datos se procesan y almacenan 100% localmente en el dispositivo utilizando `SwiftData` con soporte para cifrado SQLite por hardware.
4. **Widgets Interactivos en Lock Screen:** Tacha hábitos directamente desde la pantalla de bloqueo usando `WidgetKit` y `App Intents` en iOS 17+.
5. **Generador de Fondo de Pantalla (Wallpaper):** Genera imágenes en resolución Retina vertical (9:16) mediante `ImageRenderer` y automatiza su aplicación mediante la app nativa **Atajos** (*Shortcuts*).
6. **Sincronización de Calendarios:** Integración con `EventKit` para leer agendas externas (Apple Calendar / Google Calendar) y actualizar ante cambios (`.EKEventStoreChanged`).
7. **Notificaciones Locales:** Alertas previas (5 o 15 min) agendadas localmente con `UNCalendarNotificationTrigger`.

---

## 📁 Estructura del Código Fuente

```text
c:/Users/pamel/habitlock/
├── HabitLock/
│   ├── App/
│   │   ├── HabitLockApp.swift            # Punto de entrada de la aplicación
│   │   └── AppConstants.swift            # Constantes globales y App Group ID
│   ├── Models/
│   │   └── HabitTask.swift               # Entidad @Model de SwiftData
│   ├── Theme/
│   │   ├── ColorPalette.swift            # Paleta de colores "Calma Orgánica"
│   │   └── Typography.swift              # Estilos SF Pro (16pt/14pt)
│   ├── Services/
│   │   ├── PersistenceController.swift   # Almacén de SwiftData compartido en App Group
│   │   ├── CalendarManager.swift         # Sincronizador de EventKit
│   │   ├── LocalNotificationManager.swift# Gestor de notificaciones offline
│   │   ├── WallpaperGenerator.swift      # Generador de imágenes con ImageRenderer
│   │   └── ShortcutLauncher.swift        # Lanzador de atajos vía URL Scheme
│   ├── Intents/
│   │   └── ToggleTaskIntent.swift        # App Intent para tachar tareas desde el Widget
│   ├── Views/
│   │   ├── ContentView.swift             # Contenedor principal con TabView
│   │   ├── MainAgendaView.swift          # Vista principal ergonómica y lista de tareas
│   │   ├── CustomGlassmorphicContainerView.swift # Modal de Zoom centrado glassmorphic
│   │   ├── WallpaperDesignView.swift     # Plantilla 9:16 para exportar wallpaper
│   │   ├── HabitFormView.swift           # Formulario para crear/editar registros
│   │   └── SettingsView.swift            # Ajustes e instrucciones de Atajos
│   └── Resources/
│       └── Info.plist                    # Declaraciones de privacidad y permisos
├── HabitLockWidget/
│   ├── HabitLockWidget.swift             # Provider y Widget principal
│   └── LockScreenWidgetView.swift        # Interfaz accessoryRectangular para Lock Screen
├── habitlock-design-blueprint-v7.md      # Especificación de diseño y HIG
├── habitlock-technical-compilation.md    # Manual técnico detallado
└── habitlock-qa-checklist.md             # Plan de pruebas de control de calidad
```

---

## 🚀 Guía de Configuración en Xcode

### 1. Requisitos Previos
* Xcode 15.0+ (orientado a iOS 17+)
* macOS Sonoma o superior
* Cuenta de Apple Developer (para App Groups y Widgets interactivos)

### 2. Pasos para crear el proyecto en Xcode
1. Abre Xcode y crea un nuevo proyecto: **App (iOS)** con nombre `HabitLock` en SwiftUI y SwiftData.
2. Añade un **Target** secundario de tipo **Widget Extension** con el nombre `HabitLockWidget`.
3. Copia los archivos del código fuente respetando la estructura de carpetas.
4. En **Signing & Capabilities**:
   * En el target de **HabitLock**: Añade la capacidad **App Groups** y selecciona `group.com.empresa.habitlock`.
   * En el target de **HabitLockWidget**: Añade la misma capacidad **App Groups** marcando exactamente el mismo identificador.
5. En `Info.plist`, asegúrate de incluir los textos explicativos para los permisos de Fotos (`NSPhotoLibraryAddUsageDescription`) y Calendario (`NSCalendarsFullAccessUsageDescription`).

---

## 📱 Configuración del Atajo en iOS (Fondo de Pantalla)

1. Abre la aplicación nativa **Atajos** (*Shortcuts*) en tu iPhone.
2. Crea un nuevo atajo y nombralo exactamente **`HabitLockWallpaper`**.
3. Agrega la acción **"Establecer foto de fondo de pantalla"** (*Set Wallpaper Photo*).
4. Configura la acción para que tome la imagen de la entrada del **Portapapeles** (*Clipboard*) y la aplique a la Pantalla de Bloqueo.

---

## 🛠️ Subir a GitHub

Para sincronizar este repositorio con tu cuenta de GitHub desde tu terminal local:

```bash
git init
git add .
git commit -m "Initial commit: HabitLock iOS complete codebase architecture"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
git push -u origin main
```

---
*Desarrollado bajo las directrices de interfaz humana (HIG) de Apple e implementación offline-first.*
