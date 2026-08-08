# 🌿 Arquitectura de Integración: App Principal <-> Lock Screen Widget
Este documento técnico describe de forma exhaustiva la arquitectura de comunicación, persistencia y seguridad de **HabitLock**, detallando cómo la App Principal y la extensión del Widget en la pantalla de bloqueo coexisten y se sincronizan en tiempo real mediante un contenedor compartido de **App Groups**.

---

## 1. Diagrama de Flujo y Arquitectura de Datos

Por defecto, el sistema operativo iOS aísla (*sandbox*) las aplicaciones para impedir el acceso no autorizado de extensiones u otras apps a sus archivos. Para que **HabitLock** pueda actualizar el estado de tareas desde el widget y sincronizar la agenda del calendario en tiempo real, implementamos la siguiente arquitectura de almacenamiento unificado:

```
+----------------------------------------------------------------------------------------+
|                                    DISPOSITIVO iOS                                     |
|                                                                                        |
|   +---------------------------------------+    +-----------------------------------+   |
|   |          APP PRINCIPAL (Main)         |    |     LOCK SCREEN WIDGET (Widget)   |   |
|   |  - Consulta EventKit (Calendario)     |    |  - Muestra agenda diaria/semanal  |   |
|   |  - Interfaz de creación de tareas     |    |  - UI Reactiva (SF Pro)           |   |
|   |  - Persistencia SwiftData (AppGroup)  |    |  - Botones interactivos (Intent)  |   |
|   +-------------------+-------------------+    +-----------------+-----------------+   |
|                       |                                          |                     |
|           (Escribe)   |                                          | (Escribe / Lee)     |
|                       v                                          v                     |
|       +---------------+------------------------------------------+---------------+     |
|       |                     APP GROUP SHARED CONTAINER                           |     |
|       |                (group.com.tuempresa.habitlock)                           |     |
|       |                                                                          |     |
|       |  +--------------------------------------------------------------------+  |     |
|       |  |                       BASE DE DATOS COMPARTIDA                     |  |     |
|       |  |                  - SwiftData Store (Model.sqlite)                  |  |     |
|       |  |                  - Encriptación: FileProtectionType.complete       |  |     |
|       |  +--------------------------------------------------------------------+  |     |
|       +---------------------------------------+----------------------------------+     |
|                                               |                                        |
|                                               | (Notifica recarga de interfaz)         |
|                                               v                                        |
|                                   +-----------------------+                            |
|                                   |  WidgetCenter.shared  |                            |
|                                   |  .reloadAllTimelines()|                            |
|                                   +-----------------------+                            |
+----------------------------------------------------------------------------------------+
```

---

## 2. Componentes de la Arquitectura

### A. El Contenedor Compartido (App Groups)
*   **Función:** Actúa como el puente físico en el sistema de archivos del iPhone.
*   **Configuración:** Tanto el target de la App Principal como el de la Extensión del Widget tienen habilitada en Xcode la capacidad `App Groups` apuntando al identificador `group.com.tuempresa.habitlock` [14, 56, 60].
*   **Directorio:** En lugar de guardar la base de datos SQLite en la carpeta privada `/Documents` de la App, la base de datos se aloja en la URL devuelta por `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:)` [56, 60].

### B. El Motor de Persistencia (SwiftData + Core Data)
*   **Enfoque Offline-First:** Toda consulta de la agenda y marcado de tareas se realiza sobre la base de datos compartida local antes de intentar cualquier sincronización en la nube [49].
*   **Cifrado por Hardware (Seguridad Absoluta):** Para cumplir el compromiso de "Privacidad Primero", el archivo SQLite se inicializa con la opción `FileProtectionType.complete` [46, 48]. Esto garantiza que si el iPhone está bloqueado o apagándose, los datos de la agenda permanecen encriptados por hardware y son inaccesibles para cualquier proceso en segundo plano no autorizado [46, 48].

### C. El Mecanismo de Interacción (WidgetKit & App Intents)
*   A partir de iOS 17, el widget no es estático; permite interactuar directamente con elementos mediante `App Intents` sin necesidad de lanzar la aplicación completa [12, 55].
*   Al pulsar el botón del widget, se ejecuta un intent de segundo plano que carga de forma aislada la base de datos SQLite compartida, modifica el estado de la tarea y luego solicita la recarga de la interfaz gráfica del widget [12, 55].

---

## 3. Ciclos de Sincronización y Vida de los Datos

La sincronización se gestiona de manera predictiva y eficiente en dos direcciones para evitar consumos de batería o procesamiento redundantes:

### Ciclo 1: De la App Principal hacia el Widget (Creación/Edición)
1.  El usuario abre la app y crea o reprograma una tarea diaria en la zona de fácil alcance táctil (ergonomía) [8].
2.  La tarea se inserta en el `ModelContext` de SwiftData y se consolida en el archivo SQLite compartido [51, 60].
3.  La aplicación invoca inmediatamente la instrucción:
    ```swift
    WidgetCenter.shared.reloadAllTimelines()
    ```
4.  iOS le notifica al subsistema de widgets de la pantalla de bloqueo que la agenda ha cambiado [14, 62]. El widget recarga de forma transparente su interfaz, reflejando el nuevo recordatorio de un vistazo [12].

### Ciclo 2: Del Widget hacia la App Principal (Tachar Tarea)
1.  El usuario despierta el iPhone y ve el widget en la pantalla de bloqueo con su listado semanal de hábitos o tareas [15].
2.  Pulsa el botón de completado junto a una tarea específica [12, 55].
3.  El sistema operativo despierta la extensión del widget en segundo plano y dispara el `AppIntent` (`ToggleTaskIntent`) [12, 55].
4.  El intent lee la base de datos en el directorio compartido (`App Group`), cambia la propiedad `isCompleted` de la tarea de `false` a `true` y guarda los cambios en disco [55, 60].
5.  El intent llama a `WidgetCenter.shared.reloadAllTimelines()` [55, 62].
6.  El widget se redibuja de inmediato mostrando la tarea con el sutil efecto de tachado en color **verde salvia** y opacidad atenuada [12, 55]. Cuando el usuario abra la App Principal posteriormente, el cambio ya estará consolidado en el historial de forma nativa [58, 60].

---

## 4. El Bucle de Seguridad y Comportamiento en Bloqueo

Un punto sumamente sensible para el equipo de desarrollo es la coexistencia entre la **interactividad** y la **encriptación del dispositivo**:

1.  **Dispositivo Bloqueado (Estado Seguro):** Mientras el iPhone esté bloqueado y con la pantalla apagada, la encriptación de hardware `FileProtectionType.complete` mantiene los archivos del App Group cerrados herméticamente [46, 48].
2.  **Interacción del Widget:** Si el usuario toca el botón interactivo del widget en la pantalla de bloqueo estando bloqueado, ocurre lo siguiente:
    *   **Políticas de Seguridad de Apple:** iOS detectará que la acción requiere modificar un archivo protegido localmente [48, 55].
    *   **Interrupción de Seguridad:** iOS retendrá temporalmente la ejecución del `AppIntent` y le solicitará al usuario autenticarse de manera biométrica con **FaceID o TouchID** (o ingresar su código de acceso) [9, 55].
    *   **Desbloqueo y Ejecución:** En cuanto el usuario se autentica, el sistema de archivos del App Group se desbloquea por hardware, el `AppIntent` ejecuta su método `perform()`, actualiza el estado de la tarea en la base de datos compartida y el widget se redibuja con el nuevo progreso semanal [46, 55, 60].

---

## 5. El Rol de EventKit (Calendarios Externos)

La sincronización asíncrona de calendarios funciona como un flujo complementario que alimenta la base de datos de la arquitectura de la siguiente manera:

1.  La app solicita el acceso full a calendarios utilizando el framework `EventKit` [21].
2.  El hilo principal se registra para escuchar eventos de cambio de sistema mediante la notificación `.EKEventStoreChanged` [22].
3.  Si el usuario añade una cita en su aplicación nativa de Apple Calendar o Google Calendar, el sistema operativo despierta este listener [16, 22].
4.  La App de **HabitLock** lee los nuevos eventos del rango de la semana, valida cuáles corresponden a hábitos vinculados, actualiza la base de datos compartida SQLite y gatilla la recarga del widget para mantener la agenda totalmente unificada [22, 60].
