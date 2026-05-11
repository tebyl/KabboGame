extends Node2D

signal move_finished(npc_id: String)

const TILE_WIDTH := 64
const TILE_HEIGHT := 32
const MOVE_DURATION := 0.24
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")

var npc_id := ""
var npc_name := ""
var avatar_variant := "default"
var current_cell := Vector2i.ZERO
var current_direction := "south"
var is_moving := false
var move_tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $NameLabel
@onready var speech_bubble: Node2D = $SpeechBubble


func setup(data: Dictionary) -> void:
	npc_id = String(data.get("id", "npc"))
	npc_name = String(data.get("name", npc_id.capitalize()))
	avatar_variant = String(data.get("avatar_variant", "default"))
	current_cell = _dict_to_vector2i(data.get("cell", { "x": 0, "y": 0 }))
	name_label.text = npc_name
	set_cell(current_cell)
	update_sprite()


func set_cell(cell: Vector2i) -> void:
	current_cell = cell
	position = IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT)
	z_index = int(position.y)


func move_to_cell(cell: Vector2i) -> void:
	if is_moving:
		return
	var delta := cell - current_cell
	set_iso_direction_from_grid_delta(delta)
	current_cell = cell
	is_moving = true
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.tween_property(self, "position", IsoGridScript.grid_to_world(cell, TILE_WIDTH, TILE_HEIGHT), MOVE_DURATION)
	move_tween.finished.connect(_on_move_tween_finished)


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


func update_sprite() -> void:
	var npc_path := "res://assets/sprites/npc/%s/%s.png" % [npc_id, current_direction]
	var variant_path := "res://assets/sprites/player_variants/%s/%s.png" % [avatar_variant, current_direction]
	var base_path := "res://assets/sprites/player/%s.png" % current_direction
	var texture: Texture2D = null

	if ResourceLoader.exists(npc_path):
		texture = load(npc_path)
	elif ResourceLoader.exists(variant_path):
		texture = load(variant_path)
	elif ResourceLoader.exists(base_path):
		texture = load(base_path)

	if texture:
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.offset = Vector2(0, -texture.get_height() / 2.0)


func show_speech(text: String) -> void:
	if speech_bubble and speech_bubble.has_method("show_message"):
		speech_bubble.show_message(text)


func _on_move_tween_finished() -> void:
	is_moving = false
	z_index = int(position.y)
	move_finished.emit(npc_id)


func _dict_to_vector2i(data) -> Vector2i:
	if data is Vector2i:
		return data
	if data is Dictionary:
		return Vector2i(int(data.get("x", 0)), int(data.get("y", 0)))
	return Vector2i.ZERO
