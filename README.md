# KabboLike

KabboLike es un MVP local en Godot 4.x para un juego social isometrico inspirado en habitaciones tipo Habbo. El objetivo actual es tener una base modular: sala, jugador, muebles, decoracion, inventario, tienda local, perfil, chat, NPCs simulados y guardado JSON local.

## Estructura

- `assets/sprites/player/`: sprites base del jugador en 8 direcciones.
- `assets/sprites/player_variants/`: variantes generadas de camisa/avatar.
- `assets/sprites/npc/`: NPCs generados desde sprites del jugador.
- `assets/sprites/room/`: spritesheets de piso y paredes base.
- `assets/sprites/room/walls/`: variantes de paredes generadas con Python.
- `assets/sprites/furniture/`: spritesheets de muebles por direccion.
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
- NPCs locales simulados.
- Wall types generados desde spritesheet default.

## Ejecucion

Abrir el proyecto con Godot 4.x y ejecutar `scenes/main/Main.tscn`.

Desde consola, se puede validar carga de scripts con:

```powershell
& 'd:\Godot\Godot_v4.6.2-stable_win64.exe\Godot_v4.6.2-stable_win64.exe' --headless --path . --quit
```

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
- Inspector: rotar o eliminar mueble seleccionado.
- Tienda: comprar muebles con monedas locales.
- Perfil: cambiar nombre y variante de camisa.
- Salas: crear y cambiar sala local.

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
    "coins": 500
  },
  "inventory": {
    "chair": 5
  },
  "chat": [],
  "rooms": [
    {
      "id": "room_default",
      "name": "Mi Sala",
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

Reglas importantes:

- Inventario representa muebles disponibles.
- Muebles colocados viven dentro de cada sala.
- NPCs no se guardan todavia; son visitantes locales temporales.
- Saves version 1 se migran a `rooms`.

## Pendientes

- Separar partes de `Main.gd` y `Room.gd` cuando crezca la siguiente fase.
- Mover muebles colocados.
- Chat por sala.
- NPCs persistentes o configurables por sala.
- Permisos de sala.
- Avatar real por capas.
- Multijugador/servidor en una fase futura.
