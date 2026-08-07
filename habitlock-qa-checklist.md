# Plan de Pruebas y QA Checklist: HabitLock

Este documento contiene el conjunto de casos de prueba (QA Checklist) diseñado para verificar el comportamiento, la sincronización y la estabilidad del sistema de **HabitLock** bajo todas las condiciones del sistema operativo iOS. Está estructurado para que el equipo de control de calidad (QA) valide la implementación de extremo a extremo.

---

## Bloque 1: Interactividad en la Pantalla de Bloqueo (Widgets & App Intents)

### Caso de Prueba 1.1: Marcado de Tarea con Dispositivo Bloqueado (Seguridad)
*   **Objetivo:** Verificar que el widget interactivo respete la política de seguridad y privacidad de iOS al intentar completar una tarea con la pantalla bloqueada [56].
*   **Procedimiento de Prueba:**
    1. Bloquea el iPhone sin que FaceID te reconozca (el candado en la parte superior debe aparecer cerrado).
    2. En el widget de HabitLock de la pantalla de bloqueo, presiona el botón circular para marcar una tarea como completada [12, 15].
*   **Resultado Esperado:** 
    *   La tarea **no** debe marcarse de inmediato en segundo plano de manera silenciosa [56].
    *   iOS debe exigir de inmediato la autenticación (FaceID, TouchID o código de seguridad) antes de proceder con el App Intent [56].
    *   Tras la autenticación correcta, la tarea cambia visualmente al estado completado (cambio a color **Verde Salvia** y texto tachado de forma sutil).

### Caso de Prueba 1.2: Consistencia del Estado Compartido (App Groups)
*   **Objetivo:** Validar que la base de datos compartida por el App Group mantenga los estados idénticos e inmediatos entre el widget y la aplicación principal [14, 57, 61].
*   **Procedimiento de Prueba:**
    1. Abre la aplicación principal de HabitLock y marca un hábito o tarea como completado.
    2. Cierra o minimiza la aplicación de inmediato y bloquea la pantalla.
    3. Inspecciona el widget de la pantalla de bloqueo.
    4. Realiza el proceso inverso: tacha una tarea desde el widget de la pantalla de bloqueo, desbloquea el dispositivo y abre la app principal.
*   **Resultado Esperado:**
    *   El widget debe reflejar instantáneamente el cambio realizado en la app. El timeline del widget debe forzar su recarga inmediata invocando `WidgetCenter.shared.reloadAllTimelines()` al guardar los datos [14, 63].
    *   La aplicación principal debe mostrar la tarea tachada de inmediato sin necesidad de tirar para refrescar o reiniciar la app.

---

## Bloque 2: Regeneración de Fondos de Pantalla y Flujo Semiautomático

### Caso de Prueba 2.1: Generación de Imagen con ImageRenderer
*   **Objetivo:** Comprobar que la vista de agenda y hábitos se capture a la resolución nativa correcta y se guarde en la galería de fotos sin pixelación [53, 55].
*   **Procedimiento de Prueba:**
    1. Añade múltiples tareas y hábitos para el día actual.
    2. Presiona el botón "Guardar Fondo de Pantalla" dentro de la aplicación.
    3. Abre la aplicación nativa "Fotos" de iOS y revisa la última imagen guardada.
*   **Resultado Esperado:**
    *   El sistema debe solicitar permiso de acceso de escritura a fotos con la alerta de privacidad declarada (`Privacy - Photo Library Additions Usage Description`) si es la primera vez [53].
    *   La imagen guardada debe tener una relación de aspecto vertical (como 9:16) y coincidir con la resolución de pantalla del dispositivo de prueba (evitando estiramientos o márgenes negros) [53, 55].
    *   El texto de la agenda en la foto guardada debe ser completamente nítido [55].

### Caso de Prueba 2.2: Lanzamiento del Atajo del Sistema (Shortcuts)
*   **Objetivo:** Verificar que el portapapeles se cargue de forma segura y el deep link de Atajos se ejecute de manera fluida [1, 11].
*   **Procedimiento de Prueba:**
    1. Modifica la agenda en HabitLock para forzar la regeneración del fondo de pantalla.
    2. Presiona "Establecer como Fondo".
*   **Resultado Esperado:**
    *   La app debe copiar silenciosamente la nueva imagen generada por `ImageRenderer` al portapapeles del sistema (`UIPasteboard.general.image = image`) [1, 2].
    *   La aplicación debe abrir de inmediato el esquema de URL `shortcuts://run-shortcut?name=HabitLockWallpaper&input=clipboard` [11].
    *   El Atajo de iOS debe iniciarse y aplicar la imagen del portapapeles en la pantalla de bloqueo sin que el usuario tenga que seleccionarla manualmente de su galería [1, 11].

---

## Bloque 3: Sincronización de Datos Externos (EventKit)

### Caso de Prueba 3.1: Actualización ante Cambios de Calendario Externo
*   **Objetivo:** Comprobar que HabitLock actualice su agenda si el usuario modifica sus eventos en Apple Calendar o Google Calendar fuera de la app [22, 23].
*   **Procedimiento de Prueba:**
    1. Asegúrate de que HabitLock tenga los permisos de acceso concedidos (`NSCalendarsFullAccessUsageDescription`) [21].
    2. Abre la aplicación nativa "Calendario" de iOS o Google Calendar en un navegador y añade un nuevo evento para el día de hoy.
    3. Regresa a HabitLock (o mira su widget).
*   **Resultado Esperado:**
    *   La app debe escuchar la notificación de sistema `.EKEventStoreChanged` en segundo plano [22].
    *   Al recibirla, la app debe re-ejecutar el método de consulta `fetchCurrentWeekEvents()` para invalidar la agenda anterior y cargar los nuevos datos [22, 23].
    *   Tanto la interfaz interna de la app como el widget del Lock Screen deben actualizarse automáticamente reflejando el nuevo evento sin requerir la intervención del usuario [22, 23, 63].

---

## Bloque 4: Alertas y Notificaciones Locales (UserNotifications)

### Caso de Prueba 4.1: Activación de Recordatorio con Dispositivo Bloqueado
*   **Objetivo:** Validar que las notificaciones sutiles de aviso previo (5 o 15 minutos antes) se disparen de forma local exacta sin requerir conexión a internet [16, 18].
*   **Procedimiento de Prueba:**
    1. Crea una tarea en la agenda de HabitLock y configúrala con una alerta para 5 minutos antes del evento.
    2. Bloquea el dispositivo y desconecta la red (Wi-Fi y datos móviles) para simular un entorno offline.
    3. Espera a que llegue la hora de la notificación.
*   **Resultado Esperado:**
    *   La notificación debe aparecer en pantalla con el título, cuerpo y sonido por defecto configurados en `UNMutableNotificationContent` [18, 20].
    *   La entrega debe ocurrir de manera exacta a nivel local mediante el disparador `UNCalendarNotificationTrigger` sin retrasos del sistema [18, 19].
    *   Al tocar la notificación en la pantalla de bloqueo, el teléfono debe desbloquearse y redirigir al usuario directamente a la vista de calendario de HabitLock [16].

---

## Bloque 5: Interfaz, Accesibilidad y Diseño Emocional

### Caso de Prueba 5.1: Comportamiento del Contenedor de Zoom con Dynamic Type
*   **Objetivo:** Asegurar que la tipografía nativa de iOS (SF Pro) y el tamaño restringido del contenedor de zoom central se adapten correctamente a los ajustes de accesibilidad de iOS sin romper la interfaz [8, 36].
*   **Procedimiento de Prueba:**
    1. Ve a la app Ajustes de iOS -> Accesibilidad -> Pantalla y tamaño de texto -> Texto más grande.
    2. Activa los "Tamaños de accesibilidad más grandes" y ajusta el deslizador al nivel máximo.
    3. Abre HabitLock y activa el "zoom" sobre un día específico en la pantalla de bloqueo (o la app).
*   **Resultado Esperado:**
    *   El texto dentro del contenedor cuadrado translúcido de zoom debe escalar de manera predecible utilizando la tecnología de Dynamic Type nativa [8, 36].
    *   La tipografía debe mantener la proporción jerárquica estricta: el título del día seleccionado (SF Pro Display) debe ser como máximo **2 pt más grande** que las tareas de la lista (SF Pro Text).
    *   La lista de tareas debe incorporar barras de scroll internas o truncamiento elegante si el texto es demasiado grande, impidiendo que los elementos se desborden de los límites del contenedor cuadrado o que se superpongan entre sí.
