class_name FurnitureSpriteSheetResolver
extends RefCounted

const FURNITURE_COORDS := {
	"chair": Vector2i(0, 0),
	"lounge_chair": Vector2i(1, 0),
	"plant": Vector2i(2, 0),
	"big_plant": Vector2i(3, 0),
	"golden_plant": Vector2i(0, 1),
	"lamp": Vector2i(1, 1),
	"poster": Vector2i(2, 1),
	"floor_tile": Vector2i(3, 1),
	"sofa": Vector2i(0, 2),
	"table": Vector2i(1, 2),
	"desk": Vector2i(2, 2),
	"bookshelf": Vector2i(3, 2),
	"bed": Vector2i(0, 3),
	"rug": Vector2i(1, 3),
	"red_rug": Vector2i(2, 3),
	"blue_rug": Vector2i(3, 3),
}

const ROTATION_TO_PATH := {
	0: "res://assets/sprites/furniture/furniture_spritesheet_south-east.png",
	1: "res://assets/sprites/furniture/furniture_spritesheet_south-west.png",
	2: "res://assets/sprites/furniture/furniture_spritesheet_north-west.png",
	3: "res://assets/sprites/furniture/furniture_spritesheet_north-east.png",
}

const DEFAULT_PATH := "res://assets/sprites/furniture/furniture_spritesheet_south-east.png"
const LEGACY_PATH := "res://assets/sprites/furniture/furniture_spritesheet.png"

static var _spritesheet_cache := {}
static var _atlas_cache := {}


static func get_furniture_texture(furniture_type: String, furniture_rotation: int) -> Texture2D:
	var cache_key := "%s_%s" % [furniture_type, posmod(furniture_rotation, 4)]
	if _atlas_cache.has(cache_key):
		return _atlas_cache[cache_key]

	var spritesheet := _load_spritesheet(furniture_rotation)
	if not spritesheet:
		return null

	var atlas_cell: Vector2i = FURNITURE_COORDS.get(furniture_type, Vector2i.ZERO)
	var tile_size := Vector2i(floori(float(spritesheet.get_width()) / 4.0), floori(float(spritesheet.get_height()) / 4.0))
	var atlas := AtlasTexture.new()
	atlas.atlas = spritesheet
	atlas.region = Rect2i(atlas_cell * tile_size, tile_size)
	_atlas_cache[cache_key] = atlas
	return atlas


static func _load_spritesheet(furniture_rotation: int) -> Texture2D:
	var path := String(ROTATION_TO_PATH.get(posmod(furniture_rotation, 4), DEFAULT_PATH))
	var resolved_path := ""
	if ResourceLoader.exists(path):
		resolved_path = path
	elif ResourceLoader.exists(DEFAULT_PATH):
		resolved_path = DEFAULT_PATH
	elif ResourceLoader.exists(LEGACY_PATH):
		resolved_path = LEGACY_PATH

	if not resolved_path.is_empty():
		if not _spritesheet_cache.has(resolved_path):
			_spritesheet_cache[resolved_path] = load(resolved_path)
		return _spritesheet_cache[resolved_path]
	return null
