class_name FurnitureItem
extends Node2D

const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const FurnitureSpriteSheetResolverScript := preload("res://scripts/room/FurnitureSpriteSheetResolver.gd")
const FurnitureFootprintScript := preload("res://scripts/room/FurnitureFootprint.gd")
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")
const DebugConfigScript := preload("res://scripts/data/DebugConfig.gd")
const TILE_WIDTH := 64
const TILE_HEIGHT := 32

var furniture_id: String
var furniture_type: String
var cell := Vector2i.ZERO
var size := Vector2i(1, 1)
var furniture_rotation := 0
var selected := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var selection_highlight: Polygon2D = $SelectionHighlight


func setup(data: Dictionary) -> void:
	furniture_id = String(data.get("id", ""))
	furniture_type = String(data.get("type", "chair"))
	cell = data.get("cell", Vector2i.ZERO)
	size = FurnitureCatalogScript.get_size(furniture_type)
	furniture_rotation = int(data.get("rotation", 0))
	selected = bool(data.get("selected", false))
	update_position()
	update_visual()
	set_selected(selected)


func set_selected(value: bool) -> void:
	selected = value
	if is_node_ready():
		selection_highlight.visible = selected


func rotate_item() -> void:
	furniture_rotation = posmod(furniture_rotation + 1, 4)
	update_visual()


func update_visual() -> void:
	if not is_node_ready():
		return
	var texture := FurnitureSpriteSheetResolverScript.get_furniture_texture(furniture_type, furniture_rotation)
	if texture:
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.visible = true
		sprite.centered = true
		sprite.position = Vector2.ZERO
		sprite.offset = FurnitureFootprintScript.get_sprite_offset(
			size,
			furniture_rotation,
			Vector2(texture.get_width(), texture.get_height()),
			FurnitureCatalogScript.get_sprite_offset(furniture_type),
			TILE_WIDTH,
			TILE_HEIGHT
		)
	else:
		sprite.texture = null
	_draw_selection_highlight()
	_draw_fallback_if_needed(texture == null)
	_draw_debug_visual()


func update_position() -> void:
	position = IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT)
	z_index = int(position.y + FurnitureFootprintScript.get_visual_anchor_offset(size, furniture_rotation, TILE_WIDTH, TILE_HEIGHT).y)


func get_occupied_cells() -> Array[Vector2i]:
	return FurnitureFootprintScript.get_occupied_cells(cell, size, furniture_rotation)


func get_rotated_size() -> Vector2i:
	return FurnitureFootprintScript.get_rotated_size(size, furniture_rotation)


func _draw_selection_highlight() -> void:
	selection_highlight.polygon = FurnitureFootprintScript.get_footprint_polygon(size, furniture_rotation, TILE_WIDTH, TILE_HEIGHT)
	selection_highlight.color = Color(0.15, 0.75, 1.0, 0.30)
	selection_highlight.visible = selected


func _draw_fallback_if_needed(needs_fallback: bool) -> void:
	for child in get_children():
		if child.name == "FurnitureFallback":
			child.queue_free()
	if not needs_fallback:
		return
	var fallback := Polygon2D.new()
	fallback.name = "FurnitureFallback"
	fallback.polygon = PackedVector2Array([
		Vector2(0, -24),
		Vector2(28, -8),
		Vector2(28, 18),
		Vector2(0, 34),
		Vector2(-28, 18),
		Vector2(-28, -8),
	])
	fallback.color = Color(0.45, 0.55, 0.75)
	add_child(fallback)


func _draw_debug_visual() -> void:
	for child in get_children():
		if String(child.name).begins_with("FurnitureDebug"):
			child.queue_free()
	if not DebugConfigScript.DEBUG_MODE:
		return

	for occupied_cell in get_occupied_cells():
		var local_cell := occupied_cell - cell
		var cell_debug := Polygon2D.new()
		cell_debug.name = "FurnitureDebugCell"
		cell_debug.polygon = FurnitureFootprintScript.get_footprint_polygon(Vector2i.ONE, 0, TILE_WIDTH, TILE_HEIGHT)
		cell_debug.position = IsoGridScript.grid_to_world(local_cell, TILE_WIDTH, TILE_HEIGHT)
		cell_debug.color = Color(0.0, 0.8, 1.0, 0.18)
		cell_debug.z_index = -2
		add_child(cell_debug)

	var anchor_debug := Polygon2D.new()
	anchor_debug.name = "FurnitureDebugAnchor"
	anchor_debug.polygon = PackedVector2Array([
		Vector2(0, -5),
		Vector2(5, 0),
		Vector2(0, 5),
		Vector2(-5, 0),
	])
	anchor_debug.color = Color(1.0, 0.9, 0.0, 0.9)
	anchor_debug.z_index = 20
	add_child(anchor_debug)

	if sprite.texture:
		var rect := ReferenceRect.new()
		rect.name = "FurnitureDebugSpriteRect"
		rect.editor_only = false
		rect.border_color = Color(1.0, 0.2, 1.0, 0.8)
		rect.position = sprite.offset - Vector2(sprite.texture.get_width(), sprite.texture.get_height()) / 2.0
		rect.size = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
		rect.z_index = 19
		add_child(rect)
