# Kabbo Hotel UI Asset Pack

Pack inicial de assets UI estilo pixel-art premium azul/cian para Godot 4.

## Estructura
- `panels/`: paneles PNG con bordes para `NinePatchRect`.
- `buttons/`: estados de botones base: normal, hover, pressed, disabled.
- `icons/`: íconos 32x32 con fondo transparente.
- `badges/`: badges para dueño, actual, online, aviso y locked.
- `palette/`: paleta visual de referencia.

## Godot 4
Usa `NinePatchRect` con márgenes aproximados:
- panel_blue_9slice.png: 8 px
- panel_dark_9slice.png: 8 px
- panel_modal_9slice.png: 10 px
- chat_panel_9slice.png: 8 px

Para mantener pixel-art nítido:
- Import > Filter: Off
- Mipmaps: Off
- Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter = Nearest

## Uso sugerido
- Azul/cyan: acciones principales y navegación.
- Verde: CTA positivo, enviar, crear.
- Rojo/coral: cerrar, borrar, acciones destructivas.
- Amarillo/dorado: badges premium, activo, dueño, actual.

Assets originales generados para Kabbo Hotel. No copian recursos de Habbo ni marcas externas.
