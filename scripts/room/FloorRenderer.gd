extends RefCounted

const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")
const SPRITESHEET_PATH := "res://assets/sprites/room/room_floor_spritesheet.png"
const TILE_WIDTH  := 64
const TILE_HEIGHT := 32
const SIDE_HEIGHT := 0  # px de cara lateral visible del sprite; 0 = tile plano

const TILE_MAP := {
	"beige_basic": Vector2i(0, 0),
	"beige_dark": Vector2i(1, 0),
	"cream_basic": Vector2i(2, 0),
	"brown_basic": Vector2i(3, 0),
	"beige_border": Vector2i(0, 1),
	"beige_diagonal": Vector2i(1, 1),
	"beige_center": Vector2i(2, 1),
	"beige_worn": Vector2i(3, 1),
	"dark_tile": Vector2i(0, 2),
	"blue_tile": Vector2i(1, 2),
	"red_tile": Vector2i(2, 2),
	"green_tile": Vector2i(3, 2),
	"marble_tile": Vector2i(0, 3),
	"wood_parquet": Vector2i(1, 3),
	"checker_tile": Vector2i(2, 3),
	"premium_gold_tile": Vector2i(3, 3),
}

var layer: Node2D
var room_width := 10
var room_height := 10
var floor_type := "beige_basic"


func _init(target_layer: Node2D, width: int, height: int, type: String = "beige_basic") -> void:
	layer = target_layer
	room_width = width
	room_height = height
	floor_type = type


func redraw() -> void:
	_clear_layer()
	if ResourceLoader.exists(SPRITESHEET_PATH):
		var spritesheet := load(SPRITESHEET_PATH) as Texture2D
		_draw_atlas_floor(spritesheet)
	else:
		_draw_fallback_floor()


func _draw_atlas_floor(spritesheet: Texture2D) -> void:
	var atlas_cell: Vector2i = TILE_MAP.get(floor_type, TILE_MAP["beige_basic"])
	var tile_size := Vector2i(floori(float(spritesheet.get_width()) / 4.0), floori(float(spritesheet.get_height()) / 4.0))
	var region := Rect2i(atlas_cell * tile_size, tile_size)

	for x in range(room_width):
		for y in range(room_height):
			var sprite := Sprite2D.new()
			var atlas := AtlasTexture.new()
			atlas.atlas = spritesheet
			atlas.region = region
			sprite.texture = atlas
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position = IsoGridScript.grid_to_world(Vector2i(x, y), TILE_WIDTH, TILE_HEIGHT)
			sprite.offset = Vector2(0, float(tile_size.y - TILE_HEIGHT) / 2.0)
			sprite.z_index = int(sprite.position.y) - 1000
			layer.add_child(sprite)


func _draw_fallback_floor() -> void:
	for x in range(room_width):
		for y in range(room_height):
			var tile := Polygon2D.new()
			tile.polygon = PackedVector2Array([
				Vector2(0, -TILE_HEIGHT / 2.0),
				Vector2(TILE_WIDTH / 2.0, 0),
				Vector2(0, TILE_HEIGHT / 2.0),
				Vector2(-TILE_WIDTH / 2.0, 0),
			])
			tile.color = Color(0.78, 0.65, 0.47)
			tile.position = IsoGridScript.grid_to_world(Vector2i(x, y), TILE_WIDTH, TILE_HEIGHT)
			tile.z_index = int(tile.position.y) - 1000
			layer.add_child(tile)

			var border := Line2D.new()
			border.points = PackedVector2Array([
				Vector2(0, -TILE_HEIGHT / 2.0),
				Vector2(TILE_WIDTH / 2.0, 0),
				Vector2(0, TILE_HEIGHT / 2.0),
				Vector2(-TILE_WIDTH / 2.0, 0),
				Vector2(0, -TILE_HEIGHT / 2.0),
			])
			border.width = 1.0
			border.default_color = Color(0.48, 0.39, 0.28, 0.65)
			border.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.add_child(border)


func _clear_layer() -> void:
	for child in layer.get_children():
		child.queue_free()
