# QA Release Checklist

Usar esta lista antes de compartir una demo local.

- [ ] 1. Primer inicio sin save.
- [ ] 2. Onboarding completo.
- [ ] 3. Saltar onboarding.
- [ ] 4. Crear perfil.
- [ ] 5. Cambiar camisa.
- [ ] 6. Caminar por sala.
- [ ] 7. Pathfinding alrededor de muebles.
- [ ] 8. Comprar mueble.
- [ ] 9. Colocar mueble.
- [ ] 10. Preview verde/rojo.
- [ ] 11. Rotar preview.
- [ ] 12. Seleccionar mueble.
- [ ] 13. Rotar mueble colocado.
- [ ] 14. Eliminar mueble.
- [ ] 15. Cambiar piso.
- [ ] 16. Cambiar pared.
- [ ] 17. Crear sala.
- [ ] 18. Renombrar sala.
- [ ] 19. Duplicar sala.
- [ ] 20. Borrar sala.
- [ ] 21. Exportar sala.
- [ ] 22. Importar sala.
- [ ] 23. Enviar chat.
- [ ] 24. Ver burbuja de chat.
- [ ] 25. Ver NPCs.
- [ ] 26. NPCs no se duplican al cambiar sala.
- [ ] 27. Misiones se completan.
- [ ] 28. Recompensas se reclaman una sola vez.
- [ ] 29. Logros se desbloquean.
- [ ] 30. Tienda no permite comprar sin monedas.
- [ ] 31. Inventario no permite colocar si cantidad = 0.
- [ ] 32. Sala con owner_name=Invitado y perfil=Pikachu muestra rol Visitante.
- [ ] 33. Visitante no puede decorar, cambiar piso/pared, mover/eliminar muebles ni administrar NPCs.
- [ ] 34. Owner real puede decorar y administrar su sala.
- [ ] 35. SFX funciona en el .exe con Probar sonido.
- [ ] 36. Desactivar SFX funciona.
- [ ] 37. Rating muestra promedio y cantidad de votos.
- [ ] 38. Cambiar voto propio recalcula promedio sin subir cantidad.
- [ ] 39. Tildes y ñ se ven: Dueño, Menú, Decoración, Valoración, ¿¡.
- [ ] 40. Cama y alfombra 2x2 bloquean cuatro celdas.
- [ ] 41. Mesa, sofá y escritorio 2x1 bloquean dos celdas.
- [ ] 42. Estantería 1x2 bloquea dos celdas y rota a 2x1.
- [ ] 43. Rotar muebles recalcula preview, selección y pathfinding.
- [ ] 44. Movimiento player se ve fluido y mantiene dirección correcta.
- [ ] 45. HUD no se corta en 1100x619.
- [ ] 46. Menú secundario abre Misiones, Logros, Perfil, Tienda, Salas, NPCs y Audio.
- [ ] 47. Panel NPC permite añadir, quitar, pausar chat/movimiento y respawnear solo como owner.
- [ ] 48. NPCs generados se ven limpios, sin overlays de pelo desalineados.
- [ ] 49. Guardar/cargar funciona.
- [ ] 50. Save corrupto no crashea.
- [ ] 51. Borrar save crea default.
- [ ] 52. Export desktop ejecuta sin errores.
- [ ] 53. Chat inicia vacío después de reiniciar el juego.
- [ ] 54. Inventario activa Decora sin abrir DecorPanel.
- [ ] 55. DecorPanel solo abre desde Menú > Editar sala.

## Smoke Test Rapido

- [ ] Proyecto abre sin errores en Godot 4.x.
- [ ] `scenes/main/Main.tscn` ejecuta.
- [ ] `user://save.json` se crea o migra.
- [ ] No hay prints constantes en consola.
- [ ] El juego abre aunque falten SFX opcionales.
- [ ] El juego abre aunque falten variantes opcionales de sprites.
