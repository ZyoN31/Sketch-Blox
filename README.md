# 🎮 Nyctophi Games - Data Core Presentation (Sketch-Blox)

## 📖 Descripción General
Este proyecto es un entorno interactivo desarrollado en **Roblox Studio** utilizando **React (Roact)**. Su propósito principal es servir como escenario cinematográfico y panel de control para grabar un video educativo (formato TikTok) sobre la implementación de un **Plan de Mantenimiento de Bases de Datos Distribuidas** para la empresa de videojuegos ficticia **Nyctophi Games**.

## 🎓 Contexto Académico
* **Materia:** Base de Datos Avanzadas
* **Evidencia:** EC1 - Gestión de Base de Datos
* **Equipo de Desarrollo (DBAs de Nyctophi Games):**
    * Joshua Méndez Castillo
    * Maria Isabel Rojas Pastor
    * Jose Francisco Martinez Jacobo
* **Objetivo:** Explicar el modelo de replicación, almacenamiento, control de acceso y programación de respaldos de forma creativa y en menos de 60 segundos.

## ✨ Características Técnicas del Place
* **Interfaz de Control UI (React):** Panel lateral interactivo, moderno y escalable para gestionar las animaciones, cámaras y efectos del escenario durante la grabación.
* **Tematización Dinámica:** La paleta de colores de la interfaz se adapta automáticamente a la identidad visual de cada integrante dependiendo de su `UserId` de Roblox (Rosa, Azul o Negro).
* **Modo Grabación (Overlay):** Sistema de atajos de teclado diseñado para limpiar la pantalla de elementos intrusivos y capturar planos cinematográficos puros.

## ⌨️ Controles de Interfaz
* `[ R ]` - Despliega u oculta el menú lateral de control mediante animaciones de transición suaves.
* `[ H ]` - **Modo Cinemático / Clean Screen:** Oculta absolutamente TODA la interfaz (incluyendo el menú de React y el CoreGui nativo de Roblox) para permitir la grabación de la acción en 3D sin distracciones.

## 🚀 Roadmap de Escenas y Entregables
- [ ] **Escena 1 (Nodo Maestro):** Configuración del servidor principal, simulación de entrada de datos de jugadores y justificación del modelo.
- [ ] **Escena 2 (Replicación y Seguridad):** Animación de sincronización de datos hacia los nodos esclavos (regionales) y explicación de privilegios de acceso.
- [ ] **Escena 3 (Respaldos Automatizados):** Activación del *Scheduler*, simulación de almacenamiento en nube externa y notificación de éxito por correo electrónico.
- [ ] **Reporte Final (PPTX):** Documentación técnica incluyendo el esquema visual de fechas/horas de respaldo y las conclusiones del equipo.

## 🛠️ Tecnologías Utilizadas
* Roblox Studio (Luau)
* React para Roblox (Roact)
* TweenService (Animaciones fluidas)
* UserInputService (Manejo de atajos de teclado)