# KabboLike

KabboLike es un MVP local en Godot 4.x para un juego social isometrico inspirado en habitaciones tipo Habbo. El objetivo actual es tener una base modular: sala, jugador, muebles, decoracion, inventario, tienda local, perfil, chat, NPCs simulados y guardado JSON local.

Version demo: `0.1.0 rc2` (`VERSION.txt`).

## Estructura

- `assets/sprites/player/`: sprites base del jugador en 8 direcciones.
- `assets/sprites/player_variants/`: variantes generadas de camisa/avatar.
- `assets/sprites/npc/`: NPCs generados desde sprites del jugador.
- `assets/sprites/room/`: spritesheets de piso y paredes base.
- `assets/sprites/room/walls/`: variantes de paredes generadas con Python.
- `assets/sprites/furniture/`: spritesheets de muebles por direccion.
- `assets/audio/sfx/`: efectos de sonido opcionales.
- `scenes/main/`: escena principal orquestadora.
- `scenes/room/`: Room, Player, NPC, muebles y preview.
- `scenes/ui/`: HUD y paneles.
- `scripts/data/`: managers y catalogos.
- `scripts/room/`: logica modular de sala.
- `scripts/ui/`: scripts de paneles.
- `tools/`: generadores Python de assets.
- `docs/`: checklist de QA manual.

## Fases implementadas

- Sala isometrica con piso y paredes.
- Player con 8 direcciones y movimiento por click.
- Pathfinding basico celda a celda.
- Muebles desde spritesheet, inventario y modo Decora.
- Preview de colocacion verde/rojo con rotacion.
- DecorPanel para pisos y paredes.
- DecorInspectorPanel para mueble seleccionado.
- Guardado/carga local en `user://save.json`.
- Perfil local y variantes de camisa.
- Chat local con burbuja.
- Tienda local y monedas.
- Multiples salas locales.
- Gestion avanzada de salas locales: crear con tamano, renombrar, duplicar, borrar, importar y exportar JSON.
- Roles locales de sala: Dueño y Visitante, con permisos para preparar futuras visitas.
- Onboarding guiado para primera ejecucion y reinicio desde el boton `?`.
- Misiones, logros y recompensas locales con progreso guardado.
- Sonido SFX opcional y feedback visual para acciones principales.
- NPCs locales simulados.
- Wall types generados desde spritesheet default.

## Ejecucion

Abrir el proyecto con Godot 4.x y ejecutar `scenes/main/Main.tscn`.

Desde consola, se puede validar carga de scripts con:

```powershell
godot --headless --path . --quit
```

## Demo jugable

Abrir en Godot:

1. Abrir la carpeta del proyecto.
2. Ejecutar `scenes/main/Main.tscn`.
3. Para una prueba limpia, borrar `user://save.json` desde el sistema de archivos de usuario de Godot o usar `SaveManager.delete_save()` desde una consola/script temporal.

Exportar Windows:

1. Instalar export templates desde Godot si faltan.
2. Verificar el preset `KabboLike Demo` en `export_presets.cfg`.
3. Crear build con:

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_windows.ps1
```

Si `godot` no esta en PATH, definir `GODOT_EXE` o ajustar los candidatos de `tools/build_windows.ps1`.

Salida esperada:

```text
builds/windows/KabboLike.exe
```

Web export existe como preset opcional `KabboLike Web`, pero la demo objetivo de esta fase es Windows local.

Empaquetar para testers:

```powershell
powershell -ExecutionPolicy Bypass -File tools/package_windows.ps1
```

Salida esperada:

```text
release/KabboLike_Demo_0.1.0_Windows.zip
```

Reset de save:

- El save vive en `user://save.json`.
- `SaveManager.delete_save()` borra el save local.
- Al abrir de nuevo, el juego crea estado default.

Antes de compartir una build, ejecutar `docs/QA_RELEASE_CHECKLIST.md`.

## Generacion de assets con Python

Instalar Pillow si falta:

```powershell
pip install pillow
```

Generar variantes de camisa del player:

```powershell
python tools/generate_player_shirt_variants.py
```

Generar NPCs:

```powershell
python tools/generate_npc_variants.py
```

Generar variantes de paredes:

```powershell
python tools/generate_wall_variants.py
```

## Controles basicos

- Click en piso: caminar.
- Enter: enfocar chat o enviar mensaje.
- Decora: activar editor de sala.
- Inventario: seleccionar mueble para preview.
- Rotar preview: cambia orientacion antes de colocar.
- Click en preview valido: coloca mueble.
- Click en mueble en Decora: selecciona mueble.
- Inspector: mover, rotar o eliminar mueble seleccionado.
- Tienda: comprar muebles con monedas locales.
- Perfil: cambiar nombre y variante de camisa.
- Salas: crear y cambiar sala local.
- Menu: Info sala, editar sala, guardar, audio, reiniciar tutorial, reset local y salir.

## Save JSON

El guardado vive en `user://save.json`. Formato version 2:

```json
{
  "version": 2,
  "current_room_id": "room_default",
  "profile": {
    "name": "Invitado",
    "avatar_variant": "default"
  },
  "currency": {
    "coins": 300
  },
  "inventory": {
    "chair": 4,
    "table": 1,
    "sofa": 1,
    "plant": 2,
    "lamp": 1,
    "rug": 1
  },
  "onboarding": {
    "completed": false,
    "current_step": "welcome"
  },
  "progression": {
    "missions": {},
    "achievements": {},
    "stats": {
      "furniture_placed": 0,
      "messages_sent": 0,
      "items_bought": 0,
      "rooms_created": 0,
      "floors_changed": 0,
      "walls_changed": 0,
      "profile_updates": 0,
      "coins_earned": 0,
      "coins_spent": 0,
      "shop_opened": 0,
      "inventory_opened": 0,
      "mission_rewards_claimed": 0
    }
  },
  "settings": {
    "sfx_enabled": true,
    "sfx_volume": 0.8
  },
  "rooms": [
    {
      "id": "room_default",
      "name": "Mi Sala",
      "description": "Una sala acogedora para conversar.",
      "owner_name": "Invitado",
      "local_role": "owner",
      "room_type": "social",
      "mood": "relajada",
      "rating": 0,
      "visits": 1,
      "visit_log": [
        { "date": "2026-05-12", "count": 1 }
      ],
      "created_at": 1778587200,
      "updated_at": 1778587200,
      "width": 10,
      "height": 10,
      "floor_type": "beige_basic",
      "wall_type": "default",
      "player_cell": { "x": 4, "y": 4 },
      "furniture": []
    }
  ]
}
```

El historial de chat no se guarda por ahora: cada sesion empieza con el ChatPanel vacio y cualquier clave `"chat"` de saves antiguos se ignora al cargar.

Reglas importantes:

- Inventario representa muebles disponibles.
- Muebles colocados viven dentro de cada sala.
- Exportar sala guarda solo una sala en `user://exports/` con formato `kabbom_room`.
- Importar sala lee `user://imports/import_room.json` y genera un id local nuevo.
- `local_role` puede ser `owner` o `visitor`; las salas antiguas cargan como `owner`.
- Cada sala guarda perfil local (`description`, `room_type`, `mood`, `rating`, `visits`, `visit_log`, timestamps).
- `onboarding.completed` evita que el tutorial aparezca nuevamente; `current_step` conserva el paso activo.
- `progression` guarda stats, misiones completadas/reclamadas y logros desbloqueados.
- Duplicar una sala copia el diseno local y no afecta inventario ni economia.
- `settings` guarda sonido activado y volumen SFX.
- NPCs no se guardan todavia; son visitantes locales temporales.
- Saves version 1 se migran a `rooms`.

## Sonido y feedback

Los SFX son opcionales. Si falta un archivo, `AudioManager` lo ignora sin romper el juego.

Rutas esperadas en `assets/audio/sfx/`:

- `ui_click.ogg`
- `ui_open.ogg`
- `ui_close.ogg`
- `success.ogg`
- `error.ogg`
- `coin.ogg`
- `place_furniture.ogg`
- `rotate_furniture.ogg`
- `delete_furniture.ogg`
- `chat_send.ogg`
- `mission_complete.ogg`
- `achievement_unlock.ogg`
- `save.ogg`
- `walk_step.ogg`

El HUD incluye `Audio` para activar/desactivar SFX y ajustar volumen.

## Economia local

- Monedas iniciales: 300.
- Inventario inicial: 4 sillas, 1 mesa, 1 sofa, 2 plantas, 1 lampara y 1 alfombra.
- No hay pagos reales, economia online, marketplace ni trading.
- La tienda solo emite solicitudes de compra; `Main.gd` coordina `CurrencyManager`, `InventoryManager` y `ProgressionManager`.

Precios finales:

- Basicos: silla 25, mesa 50, planta 35, lampara 45, poster 30, alfombra 70.
- Medios: sofa 100, escritorio 120, estante 130, cama 160, planta grande 90, alfombra roja 100, alfombra azul 120.
- Premium: sillon lounge 180, planta dorada 300.

Recompensas de misiones:

- Primer mueble: 40 monedas.
- Primer saludo: 25 monedas.
- Primera compra: 35 monedas.
- Decorador inicial: 80 monedas.
- Mas espacio: 60 monedas.
- Nuevo piso: 35 monedas.
- Nueva pared: 35 monedas.
- Identidad propia: 30 monedas.
- Mirar la tienda: 20 monedas.
- Revisar inventario: 20 monedas.

## Pendientes

- Separar partes de `Main.gd` y `Room.gd` cuando crezca la siguiente fase.
- `Room.gd` ronda las 800 lineas y conviene dividirlo mas adelante en `RoomPlacementService.gd`, `RoomSelectionService.gd`, `RoomNpcController.gd` y `RoomOccupancy.gd`.
- FileDialog real para importar/exportar salas.
- Chat por sala.
- NPCs persistentes o configurables por sala.
- Avatar real por capas.
- Multijugador/servidor en una fase futura.
