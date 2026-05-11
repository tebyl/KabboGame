extends Node2D

const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const FurnitureSpriteSheetResolverScript := preload("res://scripts/room/FurnitureSpriteSheetResolver.gd")
const FurnitureFootprintScript := preload("res://scripts/room/FurnitureFootprint.gd")
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")
const TILE_WIDTH := 64
const TILE_HEIGHT := 32

var furniture_type := ""
var size := Vector2i.ONE
var furniture_rotation := 0
var valid := false
var current_cell := Vector2i.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var footprint_highlight: Polygon2D = $FootprintHighlight


func _ready() -> void:
	update_visual()


func setup(next_furniture_type: String, next_rotation: int = 0) -> void:
	furniture_type = next_furniture_type
	size = FurnitureCatalogScript.get_size(furniture_type)
	furniture_rotation = posmod(next_rotation, 4)
	update_visual()


func set_cell(cell: Vector2i) -> void:
	current_cell = cell
	position = IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT)
	z_index = int(position.y) + 1


func set_preview_rotation(next_rotation: int) -> void:
	furniture_rotation = posmod(next_rotation, 4)
	update_visual()


func set_valid(value: bool) -> void:
	valid = value
	_draw_footprint()


func update_visual() -> void:
	if not is_node_ready():
		return
	var texture := FurnitureSpriteSheetResolverScript.get_furniture_texture(furniture_type, furniture_rotation)
	if texture:
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.offset = Vector2(0, -texture.get_height() / 2.0)
		sprite.modulate = Color(1, 1, 1, 0.65)
		sprite.visible = true
	else:
		sprite.texture = null
		sprite.visible = false
	_draw_footprint()


func hide_preview() -> void:
	visible = false


func show_preview() -> void:
	visible = true


func _draw_footprint() -> void:
	if not is_node_ready():
		return
	var occupied_size := _get_rotated_size()
	var max_cell := Vector2i(occupied_size.x - 1, occupied_size.y - 1)
	footprint_highlight.polygon = PackedVector2Array([
		IsoGridScript.grid_to_world(Vector2i(0, 0), TILE_WIDTH, TILE_HEIGHT) + Vector2(0, -TILE_HEIGHT / 2.0),
		IsoGridScript.grid_to_world(Vector2i(max_cell.x, 0), TILE_WIDTH, TILE_HEIGHT) + Vector2(TILE_WIDTH / 2.0, 0),
		IsoGridScript.grid_to_world(max_cell, TILE_WIDTH, TILE_HEIGHT) + Vector2(0, TILE_HEIGHT / 2.0),
		IsoGridScript.grid_to_world(Vector2i(0, max_cell.y), TILE_WIDTH, TILE_HEIGHT) + Vector2(-TILE_WIDTH / 2.0, 0),
	])
	footprint_highlight.color = Color(0.15, 0.95, 0.35, 0.38) if valid else Color(1.0, 0.18, 0.18, 0.38)


func _get_rotated_size() -> Vector2i:
	return FurnitureFootprintScript.get_rotated_size(size, furniture_rotation)
