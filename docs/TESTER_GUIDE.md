# Tester Guide

## Como ejecutar la demo

1. Descomprimir `KabboLike_Demo_0.1.0_Windows.zip`.
2. Ejecutar `KabboLike.exe`.
3. Si Windows muestra advertencia de aplicacion no firmada, elegir ejecutar de todos modos.

## Controles basicos

- Click en piso: caminar.
- Enter: enfocar chat.
- Inventario: elegir mueble.
- Decora: colocar, mover, rotar o eliminar muebles.
- Menu: guardar, salas, info sala, editar sala, audio, tutorial y reset local.

## Que probar

- Primer inicio con onboarding.
- Movimiento y pathfinding.
- Colocar silla/mesa/sofa/cama/alfombra.
- Comprar mueble en tienda.
- Cambiar piso y pared.
- Crear/cambiar/duplicar sala.
- Editar perfil de sala.
- Enviar chat.
- Completar y reclamar misiones.
- Guardar, cerrar y reabrir.
- Resetear progreso local desde Menu.

## Donde esta el save

El save vive en la carpeta de usuario de Godot como `user://save.json`.

Desde la demo, usar `Menu > Resetear progreso local` para borrar progreso sin buscar archivos manualmente.

## Como reportar bugs

Usar este formato:

1. Que hice.
2. Que esperaba.
3. Que ocurrio.
4. Captura/video si existe.
5. Pasos para reproducir.
6. Version: KabboLike Demo 0.1.0 rc2.

## Limitaciones conocidas

- No hay multijugador real.
- NPCs son simulados localmente.
- Chat es local y temporal.
- Economia y progreso son locales.
- Export/import de salas usa archivos locales.
- Algunos SFX pueden faltar; la demo no debe crashear por eso.
