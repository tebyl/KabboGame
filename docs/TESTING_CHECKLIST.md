# KabboLike Testing Checklist

Usar esta lista antes de cerrar una fase o antes de empaquetar una build local.

## Fase 14

- [ ] 1. Abrir juego sin save.
- [ ] 2. Crear save default.
- [ ] 3. Comprar mueble.
- [ ] 4. Colocar mueble.
- [ ] 5. Preview verde/rojo.
- [ ] 6. Rotar preview.
- [ ] 7. Seleccionar mueble.
- [ ] 8. Rotar mueble colocado.
- [ ] 9. Eliminar mueble.
- [ ] 10. Ver inventario actualizado.
- [ ] 11. Cambiar piso.
- [ ] 12. Cambiar pared.
- [ ] 13. Cambiar perfil/nombre/camisa.
- [ ] 14. Enviar chat.
- [ ] 15. Ver burbuja de chat.
- [ ] 16. Ver NPCs.
- [ ] 17. Cambiar sala.
- [ ] 18. Crear sala nueva.
- [ ] 19. Volver a sala anterior.
- [ ] 20. Guardar/cargar.
- [ ] 21. Cargar save antiguo si existe.
- [ ] 22. Probar pathfinding alrededor de muebles.
- [ ] 23. Probar paneles sin clicks atravesados.
- [ ] 24. Borrar save y crear default.

## Arranque y guardado

- [ ] Abrir el proyecto en Godot 4.x sin errores.
- [ ] Ejecutar la escena principal.
- [ ] Abrir sin save y confirmar bienvenida de onboarding.
- [ ] Saltar tutorial y confirmar que no vuelve al reabrir.
- [ ] Reiniciar tutorial con el boton `?`.
- [ ] Completar paso de perfil guardando nombre/camisa.
- [ ] Completar paso de caminar moviendo al jugador.
- [ ] Completar paso de inventario abriendo Inventario.
- [ ] Completar paso de Decora activando Decora.
- [ ] Completar paso de colocar mueble colocando uno.
- [ ] Completar paso de tienda abriendo Tienda.
- [ ] Completar paso de chat enviando mensaje.
- [ ] Completar paso de guardar con Guardar.
- [ ] Borrar `user://save.json` y confirmar que se crea una sala por defecto.
- [ ] Cargar un save viejo version 1 y confirmar que migra a `rooms`.
- [ ] Cargar un save version 2 y confirmar que conserva sala actual.
- [ ] Corromper temporalmente `save.json` y confirmar que el juego no crashea.

## Salas

- [ ] Abrir el panel Salas.
- [ ] Crear una sala nueva.
- [ ] Crear una sala nueva 12x12.
- [ ] Renombrar una sala.
- [ ] Duplicar una sala con piso, pared y muebles.
- [ ] Borrar una sala no actual.
- [ ] Intentar borrar la ultima sala y confirmar que no se permite.
- [ ] Borrar la sala actual y confirmar que carga otra sala.
- [ ] Exportar una sala a `user://exports/`.
- [ ] Importar una sala desde `user://imports/import_room.json`.
- [ ] Cambiar rol local de una sala a Visitante.
- [ ] Confirmar que HUD muestra Visitante.
- [ ] Confirmar que Visitante puede caminar y chatear.
- [ ] Confirmar que Visitante no puede activar Decora.
- [ ] Confirmar que Visitante no puede colocar, rotar ni eliminar muebles.
- [ ] Confirmar que Visitante no puede renombrar, borrar, duplicar ni exportar sala.
- [ ] Cambiar rol local de vuelta a Dueño.
- [ ] Confirmar que Dueño recupera permisos de decoracion y administracion.
- [ ] Cambiar entre sala 1 y sala 2.
- [ ] Confirmar que cada sala conserva sus muebles propios.
- [ ] Guardar, cerrar y abrir; confirmar que carga la ultima sala actual.

## Decoracion

- [ ] Activar modo Decora.
- [ ] Cambiar piso a `wood_parquet`.
- [ ] Confirmar mision/logro por cambiar piso.
- [ ] Cambiar pared a `blue`.
- [ ] Confirmar mision/logro por cambiar pared.
- [ ] Cambiar pared a `dark`.
- [ ] Guardar, cerrar y abrir; confirmar que piso y pared se conservan.
- [ ] Desactivar Decora y confirmar que el jugador vuelve a caminar.

## Inventario y muebles

- [ ] Comprar una silla desde Tienda.
- [ ] Confirmar que baja monedas y sube inventario.
- [ ] Confirmar mision/logro de primera compra.
- [ ] Seleccionar silla desde Inventario.
- [ ] Ver preview verde en celda valida.
- [ ] Ver preview rojo sobre celda ocupada o fuera de sala.
- [ ] Rotar preview.
- [ ] Colocar silla.
- [ ] Confirmar mision/logro de primer mueble.
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
- [ ] Confirmar mision/logro por actualizar perfil.
- [ ] Cerrar y abrir; confirmar perfil persistente.
- [ ] Enviar chat con Enter.
- [ ] Confirmar mision/logro de primer mensaje.
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

## Misiones y logros

- [ ] Abrir panel Misiones desde HUD.
- [ ] Ver misiones pendientes, completadas y reclamadas.
- [ ] Reclamar recompensa de mision completada.
- [ ] Confirmar que monedas o inventario se actualizan.
- [ ] Confirmar que no se puede reclamar dos veces.
- [ ] Abrir panel Logros desde HUD.
- [ ] Confirmar logros desbloqueados y bloqueados.
- [ ] Guardar, cerrar y abrir; confirmar progreso persistente.

## Economia local

- [ ] Nuevo save inicia con 300 monedas.
- [ ] Nuevo save inicia con inventario basico balanceado.
- [ ] Tienda muestra precio e inventario por item.
- [ ] Comprar silla descuenta 25 monedas.
- [ ] Comprar suma stock de silla en inventario.
- [ ] Comprar sin monedas suficientes deja boton deshabilitado.
- [ ] Abrir tienda completa mision de tienda.
- [ ] Abrir inventario completa mision de inventario.
- [ ] Reclamar mision suma monedas.
- [ ] Intentar reclamar dos veces no duplica recompensa.
- [ ] Confirmar `coins_spent` sube al comprar.
- [ ] Confirmar `coins_earned` sube al reclamar recompensa.
- [ ] Abrir `user://save.json` y verificar stats nuevas.

## Sonido y feedback

- [ ] El juego abre sin errores aunque falten archivos `.ogg`.
- [ ] Agregar temporalmente `ui_open.ogg` y confirmar sonido al abrir panel.
- [ ] Comprar mueble reproduce `coin.ogg` si existe.
- [ ] Compra fallida reproduce `error.ogg` si existe.
- [ ] Colocar mueble reproduce `place_furniture.ogg` si existe.
- [ ] Rotar/eliminar mueble reproduce su SFX si existe.
- [ ] Enviar chat reproduce `chat_send.ogg` si existe.
- [ ] Completar mision reproduce `mission_complete.ogg` si existe.
- [ ] Desbloquear logro reproduce `achievement_unlock.ogg` si existe.
- [ ] Abrir HUD Audio, desactivar SFX y confirmar silencio.
- [ ] Cambiar volumen SFX, guardar y reabrir; confirmar persistencia.
- [ ] Toasts muestran prefijo por tipo: `[OK]`, `[!]`, `[MISION]`, `[LOGRO]`.

## Hotfix UX / Bugs criticos

- [ ] Reiniciar juego y confirmar que el ChatPanel arranca vacio.
- [ ] Confirmar que mensajes viejos de NPCs no reaparecen despues de cerrar y abrir.
- [ ] Click en Inventario con Decora OFF activa Decora y abre solo InventoryPanel.
- [ ] Confirmar que Decora ON no abre automaticamente pisos/paredes.
- [ ] Abrir Menu > Editar sala y confirmar que recien ahi aparece DecorPanel.
- [ ] Confirmar que InventoryPanel y DecorPanel no quedan superpuestos.
- [ ] Confirmar que el tutorial no tapa InventoryPanel durante el paso de inventario.
- [ ] Probar HUD en 1100x619 y 1280x720: no debe cortarse por los bordes.
- [ ] Abrir Menu > Misiones, Logros, Perfil, Tienda, Salas y NPCs.
- [ ] Confirmar que sofa/mesa/escritorio ocupan 2x1.
- [ ] Confirmar que estante ocupa 1x2.
- [ ] Confirmar que cama y alfombras ocupan 2x2.
- [ ] Confirmar que preview verde/rojo respeta footprints multicelda.
- [ ] Confirmar que pathfinding evita todas las celdas ocupadas por muebles grandes.
- [ ] Guardar/cargar save viejo con sizes malos y confirmar que se corrige desde catalogo.
- [ ] Abrir Menu > NPCs, anadir/quitar NPC y respawnear defaults.
- [ ] Desactivar movimiento/chat NPC desde el panel y confirmar que se detienen.
- [ ] Revisar NPCs generados: no deben tener overlays de pelo/accesorios desalineados.
- [ ] Confirmar movimiento del jugador con easing suave entre celdas.
- [ ] Confirmar que el menu desplegable usa fondo azul oscuro y hover visible.
- [ ] Minimizar ChatPanel y confirmar que queda como barra compacta.
- [ ] Expandir ChatPanel y confirmar historial + input.
- [ ] Esperar NPC chat y confirmar maximo aproximado de 3 mensajes por minuto.
- [ ] Confirmar que Mira, Neo, Nova, Luna y Pixel aparecen separados al iniciar.
- [ ] Probar resize entre 1100x619 y 1280x720 y confirmar sala centrada.
