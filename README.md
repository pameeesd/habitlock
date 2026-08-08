# HabitLock - App para iOS (SwiftUI & SwiftData)

**HabitLock** es una aplicación para iOS diseñada para integrar la planificación de la agenda y la consolidación de hábitos saludables directamente en la Pantalla de Bloqueo (Lock Screen) del iPhone.

---

## 🌿 Características Principales

1. **Diseño de Calma Orgánica:** Paleta armónica basada en Verde Salvia, Verde Bosque/Pino, Crema y Verde Eucalipto para evitar la fatiga visual.
2. **Ergonomía Adaptada a iOS:** Zonas de alcance distribuidas para interacción cómoda con una sola mano (pulgar) y gestos de deslizamiento.
3. **Privacidad Offline-First:** Los datos se procesan y almacenan 100% localmente en el dispositivo utilizando `SwiftData` con soporte para cifrado SQLite por hardware.
4. **Widgets Interactivos en Lock Screen:** Tacha hábitos directamente desde la pantalla de bloqueo usando `WidgetKit` y `App Intents` en iOS 17+.
5. **Integración Exclusiva con Lock Screen Widgets:** Visualización de agenda y marcado interactivo mediante `WidgetKit` y `AppIntents` de iOS 17+. *(Nota: La generación de fondos de pantalla/wallpapers vía Atajos está excluida del alcance del producto)*.
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
│   │   ├── Habit.swift                   # Entidad @Model de Hábitos (marcador, color)
│   │   └── HabitTask.swift               # Entidad @Model de Tareas vinculadas
│   ├── Theme/
│   │   ├── ColorPalette.swift            # Paleta de colores "Calma Orgánica"
│   │   └── Typography.swift              # Estilos SF Pro (16pt/14pt)
│   ├── Services/
│   │   ├── PersistenceController.swift   # Almacén de SwiftData compartido en App Group
│   │   ├── CalendarManager.swift         # Sincronizador de EventKit
│   │   └── LocalNotificationManager.swift# Gestor de notificaciones offline
│   ├── Intents/
│   │   └── ToggleTaskIntent.swift        # App Intent para tachar tareas desde el Widget
│   ├── Views/
│   │   ├── ContentView.swift             # Contenedor principal con TabView
│   │   ├── MainAgendaView.swift          # Vista principal ergonómica y lista de tareas
│   │   ├── CustomGlassmorphicContainerView.swift # Modal de Zoom centrado glassmorphic
│   │   ├── HabitFormView.swift           # Formulario para crear/editar registros
│   │   └── SettingsView.swift            # Ajustes e instrucciones de Widgets
│   └── Resources/
│       └── Info.plist                    # Declaraciones de privacidad y permisos
├── HabitLockWidget/
│   ├── HabitLockWidget.swift             # Provider y Widget principal
│   └── LockScreenWidgetView.swift        # Interfaz accessoryRectangular para Lock Screen
├── habitlock-app-widget-architecture.md  # Arquitectura App-Widget compartida
├── habitlock-design-blueprint-v7.md      # Especificación de diseño y HIG
├── habitlock-technical-compilation-v2 (1).md # Manual técnico detallado v2
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
   * En el target de **HabitLock**: Añade la capacidad **App Groups** y selecciona `group.com.tuempresa.habitlock`.
   * En el target de **HabitLockWidget**: Añade la misma capacidad **App Groups** marcando exactamente el mismo identificador.
5. En `Info.plist`, asegúrate de incluir los textos explicativos para los permisos de Calendario (`NSCalendarsFullAccessUsageDescription`).

---

## 📱 Añadir Widgets a la Pantalla de Bloqueo

1. Mantén presionada la pantalla de bloqueo de tu iPhone y pulsa **Personalizar**.
2. Selecciona la pantalla de bloqueo y pulsa en el área de **Añadir widgets**.
3. Busca **HabitLock** en la lista de aplicaciones.
4. Arrastra el widget de lista rectangular o el widget de anillo circular a tu pantalla de bloqueo.

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
