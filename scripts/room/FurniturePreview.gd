extends Node2D

const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const FurnitureSpriteSheetResolverScript := preload("res://scripts/room/FurnitureSpriteSheetResolver.gd")
const FurnitureFootprintScript := preload("res://scripts/room/FurnitureFootprint.gd")
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")
const UiFeedbackScript := preload("res://scripts/ui/UiFeedback.gd")
const DebugConfigScript := preload("res://scripts/data/DebugConfig.gd")
const TILE_WIDTH := 64
const TILE_HEIGHT := 32

var furniture_type := ""
var size := Vector2i.ONE
var furniture_rotation := 0
var valid := false
var current_cell := Vector2i.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var footprint_highlight: Polygon2D = $FootprintHighlight
@onready var footprint_outline: Line2D = $FootprintOutline
@onready var invalid_reason_label: Label = $InvalidReason


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
	z_index = int(position.y + FurnitureFootprintScript.get_visual_anchor_offset(size, furniture_rotation, TILE_WIDTH, TILE_HEIGHT).y) + 1


func set_preview_rotation(next_rotation: int) -> void:
	furniture_rotation = posmod(next_rotation, 4)
	update_visual()


func set_valid(value: bool, reason: String = "") -> void:
	var changed := valid != value
	valid = value
	_draw_footprint(reason)
	if changed:
		UiFeedbackScript.pulse(footprint_highlight)


func show_invalid_feedback() -> void:
	UiFeedbackScript.flash(footprint_highlight, Color(1.0, 0.05, 0.05, 0.65))
	UiFeedbackScript.shake(self)


func update_visual() -> void:
	if not is_node_ready():
		return
	var texture := FurnitureSpriteSheetResolverScript.get_furniture_texture(furniture_type, furniture_rotation)
	if texture:
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
		sprite.modulate = Color(1, 1, 1, 0.65)
		sprite.visible = true
	else:
		sprite.texture = null
		sprite.visible = false
	_draw_footprint()
	_draw_debug_visual()


func hide_preview() -> void:
	visible = false


func show_preview() -> void:
	visible = true


func _draw_footprint(reason: String = "") -> void:
	if not is_node_ready():
		return
	footprint_highlight.polygon = FurnitureFootprintScript.get_footprint_polygon(size, furniture_rotation, TILE_WIDTH, TILE_HEIGHT)
	footprint_highlight.color = Color(0.15, 0.95, 0.35, 0.38) if valid else Color(1.0, 0.18, 0.18, 0.38)
	var outline_points := footprint_highlight.polygon.duplicate()
	if outline_points.size() > 0:
		outline_points.append(outline_points[0])
	footprint_outline.points = outline_points
	footprint_outline.default_color = Color(0.45, 1.0, 0.58, 0.95) if valid else Color(1.0, 0.48, 0.48, 0.95)
	invalid_reason_label.visible = not valid and not reason.is_empty()
	invalid_reason_label.text = reason


func _get_rotated_size() -> Vector2i:
	return FurnitureFootprintScript.get_rotated_size(size, furniture_rotation)


func _draw_debug_visual() -> void:
	for child in get_children():
		if String(child.name).begins_with("FurnitureDebug"):
			child.queue_free()
	if not DebugConfigScript.DEBUG_MODE:
		return

	var occupied_size := _get_rotated_size()
	for x in range(occupied_size.x):
		for y in range(occupied_size.y):
			var cell_debug := Polygon2D.new()
			cell_debug.name = "FurnitureDebugCell"
			cell_debug.polygon = FurnitureFootprintScript.get_footprint_polygon(Vector2i.ONE, 0, TILE_WIDTH, TILE_HEIGHT)
			cell_debug.position = IsoGridScript.grid_to_world(Vector2i(x, y), TILE_WIDTH, TILE_HEIGHT)
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
