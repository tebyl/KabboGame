extends Node2D

signal move_finished

const TILE_WIDTH := 64
const TILE_HEIGHT := 32
const MOVE_DURATION := 0.24
const BOB_OFFSET := -2.0
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")

var current_cell := Vector2i.ZERO
var direction_textures: Dictionary = {}
var current_direction := "south"
var avatar_variant := "default"
var move_tween: Tween
var profile_data := {
	"name": "Invitado",
	"avatar_variant": "default",
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var speech_bubble: Node2D = $SpeechBubble


func _ready() -> void:
	_load_direction_textures()
	update_sprite()
	z_index = int(position.y)


func set_direction(direction: String) -> void:
	current_direction = direction
	update_sprite()


func set_iso_direction_from_grid_delta(delta: Vector2i) -> void:
	if delta == Vector2i.ZERO:
		return

	var step := Vector2i(clampi(delta.x, -1, 1), clampi(delta.y, -1, 1))
	var direction_map := {
		Vector2i(1, 0): "south-east",
		Vector2i(-1, 0): "north-west",
		Vector2i(0, 1): "south-west",
		Vector2i(0, -1): "north-east",
		Vector2i(1, 1): "south",
		Vector2i(-1, -1): "north",
		Vector2i(1, -1): "east",
		Vector2i(-1, 1): "west",
	}
	set_direction(direction_map.get(step, "south"))


func set_cell(cell: Vector2i) -> void:
	current_cell = cell
	position = IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT)
	z_index = int(position.y)


func move_to_cell(cell: Vector2i) -> void:
	if cell == current_cell:
		move_finished.emit()
		return
	var delta := cell - current_cell
	set_iso_direction_from_grid_delta(delta)
	current_cell = cell
	var target_position := IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT)
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.set_trans(Tween.TRANS_SINE)
	move_tween.set_ease(Tween.EASE_IN_OUT)
	move_tween.set_parallel(true)
	move_tween.tween_property(self, "position", target_position, MOVE_DURATION)
	move_tween.tween_property(sprite, "position:y", BOB_OFFSET, MOVE_DURATION * 0.5)
	move_tween.chain().tween_property(sprite, "position:y", 0.0, MOVE_DURATION * 0.5)
	move_tween.finished.connect(_on_move_tween_finished)


func apply_profile(next_profile_data: Dictionary) -> void:
	profile_data = next_profile_data.duplicate(true)
	set_avatar_variant(String(profile_data.get("avatar_variant", "default")))


func set_avatar_variant(variant: String) -> void:
	avatar_variant = variant if not variant.strip_edges().is_empty() else "default"
	update_sprite()


func update_sprite() -> void:
	var variant_path := "res://assets/sprites/player_variants/%s/%s.png" % [avatar_variant, current_direction]
	var base_path := "res://assets/sprites/player/%s.png" % current_direction
	var texture: Texture2D = null

	if ResourceLoader.exists(variant_path):
		texture = load(variant_path)
	elif ResourceLoader.exists(base_path):
		texture = load(base_path)
	elif direction_textures.has(current_direction):
		texture = direction_textures.get(current_direction)

	if texture:
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.offset = Vector2(0, -texture.get_height() / 2.0)
		sprite.modulate = Color.WHITE
	else:
		_draw_fallback_player(current_direction)


func show_speech(text: String) -> void:
	if speech_bubble and speech_bubble.has_method("show_message"):
		speech_bubble.show_message(text)


func _on_move_tween_finished() -> void:
	z_index = int(position.y)
	move_finished.emit()


func _load_direction_textures() -> void:
	for direction in [
		"east",
		"west",
		"north",
		"south",
		"north-east",
		"north-west",
		"south-east",
		"south-west",
	]:
		var path := "res://assets/sprites/player/%s.png" % direction
		if ResourceLoader.exists(path):
			direction_textures[direction] = load(path)


func _draw_fallback_player(_direction: String) -> void:
	var image := Image.create(32, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var body_color := Color(0.23, 0.42, 0.86)
	var face_color := Color(0.97, 0.77, 0.55)
	for x in range(10, 22):
		for y in range(14, 28):
			image.set_pixel(x, y, face_color)
	for x in range(8, 24):
		for y in range(26, 44):
			image.set_pixel(x, y, body_color)
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.offset = Vector2(0, -24)
