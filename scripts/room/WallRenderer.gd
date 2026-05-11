class_name WallRenderer
extends RefCounted

const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")

const WALL_LEFT_PATH := "res://assets/sprites/room/wall_left.png"
const WALL_RIGHT_PATH := "res://assets/sprites/room/wall_right.png"
const WALL_CORNER_PATH := "res://assets/sprites/room/wall_corner.png"

const TILE_WIDTH := 64
const TILE_HEIGHT := 32
const WALL_HEIGHT := 96
const WALL_OFFSET := Vector2(0, float(TILE_HEIGHT) / 2.0 - float(WALL_HEIGHT) / 2.0)

const WALL_TYPE_TO_TINT := {
	"default": Color(1, 1, 1, 1),
	"trim": Color(1.08, 1.00, 0.88, 1),
	"dark": Color(0.52, 0.58, 0.72, 1),
	"pastel": Color(1.12, 0.88, 1.02, 1),
	"blue": Color(0.68, 0.84, 1.16, 1),
	"green": Color(0.74, 1.08, 0.82, 1),
	"red": Color(1.10, 0.72, 0.68, 1),
	"purple": Color(0.92, 0.76, 1.16, 1),
}

var layer: Node2D
var room_width := 10
var room_height := 10
var wall_type := "default"


func _init(target_layer: Node2D, width: int, height: int, type: String = "default") -> void:
	layer = target_layer
	room_width = width
	room_height = height
	wall_type = sanitize_wall_type(type)


func redraw() -> void:
	_clear_layer()
	var tex_left := _load_texture(WALL_LEFT_PATH)
	var tex_right := _load_texture(WALL_RIGHT_PATH)
	var tex_corner := _load_texture(WALL_CORNER_PATH)
	if tex_left and tex_right and tex_corner:
		_draw_walls(tex_left, tex_right, tex_corner)
	else:
		_draw_fallback_walls()


static func sanitize_wall_type(value: String) -> String:
	return value if WALL_TYPE_TO_TINT.has(value) else "default"


func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	push_warning("WallRenderer: no se encontro " + path)
	return null


func _draw_walls(tex_left: Texture2D, tex_right: Texture2D, tex_corner: Texture2D) -> void:
	for x in range(room_width):
		var pos := IsoGridScript.grid_to_world(Vector2i(x, -1), TILE_WIDTH, TILE_HEIGHT)
		_add_wall_sprite(tex_right, pos)

	for y in range(room_height):
		var pos := IsoGridScript.grid_to_world(Vector2i(-1, y), TILE_WIDTH, TILE_HEIGHT)
		_add_wall_sprite(tex_left, pos)

	var corner_pos := IsoGridScript.grid_to_world(Vector2i(-1, -1), TILE_WIDTH, TILE_HEIGHT)
	_add_wall_sprite(tex_corner, corner_pos)


func _add_wall_sprite(tex: Texture2D, pos: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = pos
	sprite.offset = WALL_OFFSET
	sprite.modulate = WALL_TYPE_TO_TINT.get(wall_type, WALL_TYPE_TO_TINT["default"])
	sprite.z_index = int(pos.y) - 500
	layer.add_child(sprite)


func _draw_fallback_walls() -> void:
	for x in range(room_width):
		var pos := IsoGridScript.grid_to_world(Vector2i(x, -1), TILE_WIDTH, TILE_HEIGHT)
		_add_fallback_wall(pos, true)
	for y in range(room_height):
		var pos := IsoGridScript.grid_to_world(Vector2i(-1, y), TILE_WIDTH, TILE_HEIGHT)
		_add_fallback_wall(pos, false)


func _add_fallback_wall(pos: Vector2, is_right: bool) -> void:
	var wall := Polygon2D.new()
	if is_right:
		wall.polygon = PackedVector2Array([
			Vector2(-TILE_WIDTH / 2.0, -WALL_HEIGHT),
			Vector2(0, -WALL_HEIGHT + TILE_HEIGHT / 2.0),
			Vector2(0, TILE_HEIGHT / 2.0),
			Vector2(-TILE_WIDTH / 2.0, 0),
		])
		wall.color = Color(0.60, 0.70, 0.78)
	else:
		wall.polygon = PackedVector2Array([
			Vector2(TILE_WIDTH / 2.0, -WALL_HEIGHT),
			Vector2(0, -WALL_HEIGHT + TILE_HEIGHT / 2.0),
			Vector2(0, TILE_HEIGHT / 2.0),
			Vector2(TILE_WIDTH / 2.0, 0),
		])
		wall.color = Color(0.52, 0.62, 0.70)
	wall.position = pos
	wall.z_index = int(pos.y) - 500
	layer.add_child(wall)


func _clear_layer() -> void:
	for child in layer.get_children():
		child.queue_free()
