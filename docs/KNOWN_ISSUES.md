# Known Issues

- No hay multijugador real; todo es local.
- NPCs son locales simulados y no representan visitantes reales.
- Chat es local, temporal y no se guarda entre sesiones.
- Economía, monedas, misiones y logros son locales.
- Export/import de salas usa archivos locales.
- Duplicar sala copia el diseño y no descuenta inventario; es una decisión temporal para el MVP.
- Avatar aún no usa un sistema completo de capas.
- Los overlays de pelo/accesorios de NPC estan desactivados temporalmente; se usan recolores seguros para evitar sprites corruptos.
- Audio depende de assets disponibles en `assets/audio/sfx/`; si faltan, se ignoran.
- Web export queda como preset opcional y puede requerir ajustes segun templates/navegador.
- El build Windows es el objetivo de release; Web no bloquea v0.1.0.
- `Room.gd` sigue siendo grande y conviene dividirlo más adelante.
- Si el jugador ya está caminando, un nuevo click espera a que termine la ruta actual; cancelar/recalcular rutas a mitad de tween queda pendiente.
- Resetear progreso local borra el save del usuario actual de la demo; no hay recuperación posterior.

## Limitaciones De Release Local

- No hay instalador.
- No hay actualizador.
- No hay guardado cloud.
- No hay validacion anti-trampa porque el save es local.
