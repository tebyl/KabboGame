class_name FurnitureItem
extends Node2D

const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const FurnitureSpriteSheetResolverScript := preload("res://scripts/room/FurnitureSpriteSheetResolver.gd")
const FurnitureFootprintScript := preload("res://scripts/room/FurnitureFootprint.gd")
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")
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
	size = data.get("size", FurnitureCatalogScript.get_size(furniture_type))
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
		sprite.offset = Vector2(0, -texture.get_height() / 2.0)
	else:
		sprite.texture = null
	_draw_selection_highlight()
	_draw_fallback_if_needed(texture == null)


func update_position() -> void:
	position = IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT)
	z_index = int(position.y)


func get_occupied_cells() -> Array[Vector2i]:
	return FurnitureFootprintScript.get_occupied_cells(cell, size, furniture_rotation)


func get_rotated_size() -> Vector2i:
	return FurnitureFootprintScript.get_rotated_size(size, furniture_rotation)


func _draw_selection_highlight() -> void:
	var points := PackedVector2Array()
	var occupied_size := get_rotated_size()
	var max_cell := Vector2i(occupied_size.x - 1, occupied_size.y - 1)
	points.append(IsoGridScript.grid_to_world(Vector2i(0, 0), TILE_WIDTH, TILE_HEIGHT) + Vector2(0, -TILE_HEIGHT / 2.0))
	points.append(IsoGridScript.grid_to_world(Vector2i(max_cell.x, 0), TILE_WIDTH, TILE_HEIGHT) + Vector2(TILE_WIDTH / 2.0, 0))
	points.append(IsoGridScript.grid_to_world(max_cell, TILE_WIDTH, TILE_HEIGHT) + Vector2(0, TILE_HEIGHT / 2.0))
	points.append(IsoGridScript.grid_to_world(Vector2i(0, max_cell.y), TILE_WIDTH, TILE_HEIGHT) + Vector2(-TILE_WIDTH / 2.0, 0))
	selection_highlight.polygon = points
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
