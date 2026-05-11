# KabboLike Testing Checklist

Usar esta lista antes de cerrar una fase o antes de empaquetar una build local.

## Arranque y guardado

- [ ] Abrir el proyecto en Godot 4.x sin errores.
- [ ] Ejecutar la escena principal.
- [ ] Borrar `user://save.json` y confirmar que se crea una sala por defecto.
- [ ] Cargar un save viejo version 1 y confirmar que migra a `rooms`.
- [ ] Cargar un save version 2 y confirmar que conserva sala actual.
- [ ] Corromper temporalmente `save.json` y confirmar que el juego no crashea.

## Salas

- [ ] Abrir el panel Salas.
- [ ] Crear una sala nueva.
- [ ] Cambiar entre sala 1 y sala 2.
- [ ] Confirmar que cada sala conserva sus muebles propios.
- [ ] Guardar, cerrar y abrir; confirmar que carga la última sala actual.

## Decoracion

- [ ] Activar modo Decora.
- [ ] Cambiar piso a `wood_parquet`.
- [ ] Cambiar pared a `blue`.
- [ ] Cambiar pared a `dark`.
- [ ] Guardar, cerrar y abrir; confirmar que piso y pared se conservan.
- [ ] Desactivar Decora y confirmar que el jugador vuelve a caminar.

## Inventario y muebles

- [ ] Comprar una silla desde Tienda.
- [ ] Confirmar que baja monedas y sube inventario.
- [ ] Seleccionar silla desde Inventario.
- [ ] Ver preview verde en celda valida.
- [ ] Ver preview rojo sobre celda ocupada o fuera de sala.
- [ ] Rotar preview.
- [ ] Colocar silla.
- [ ] Colocar sofa y confirmar que ocupa 2 celdas.
- [ ] Rotar sofa y confirmar huella 1x2.
- [ ] Seleccionar mueble colocado.
- [ ] Confirmar que aparece DecorInspectorPanel.
- [ ] Rotar mueble seleccionado.
- [ ] Intentar rotar si colisiona y confirmar toast de fallo.
- [ ] Eliminar mueble y confirmar que vuelve al inventario.

## Movimiento y pathfinding

- [ ] Click en piso vacio mueve al jugador celda a celda.
- [ ] Click sobre mueble fuera de Decora no mueve al jugador.
- [ ] Colocar sofa y confirmar que el jugador lo rodea.
- [ ] Bloquear una zona sin salida y confirmar que aparece mensaje de ruta no disponible.
- [ ] Confirmar que muebles eliminados liberan celdas.

## Perfil y chat

- [ ] Abrir Perfil.
- [ ] Cambiar nombre.
- [ ] Cambiar variante de camisa.
- [ ] Guardar perfil y confirmar HUD actualizado.
- [ ] Cerrar y abrir; confirmar perfil persistente.
- [ ] Enviar chat con Enter.
- [ ] Confirmar mensaje en historial.
- [ ] Confirmar burbuja sobre jugador.
- [ ] Mientras el input de chat tiene foco, hacer click en sala y confirmar que no mueve.

## NPCs

- [ ] Confirmar que aparecen Mira, Pixel y Nova.
- [ ] Confirmar que muestran nombre.
- [ ] Confirmar que usan sprites desde `assets/sprites/npc/`.
- [ ] Esperar movimiento aleatorio.
- [ ] Confirmar que no pisan muebles.
- [ ] Confirmar que no se superponen entre ellos ni con jugador.
- [ ] Cambiar sala y confirmar que no se duplican.
- [ ] Confirmar burbujas de chat NPC ocasionales.

## Fallbacks de assets

- [ ] Renombrar temporalmente un wall type PNG y confirmar fallback.
- [ ] Renombrar temporalmente spritesheet de muebles y confirmar fallback visual.
- [ ] Renombrar temporalmente variante de player y confirmar fallback al sprite base.
- [ ] Restaurar todos los assets temporales.
