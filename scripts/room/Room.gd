extends Node2D

signal player_moved(cell: Vector2i)
signal furniture_place_requested(furniture_type: String, cell: Vector2i, furniture_rotation: int)
signal furniture_removed_to_inventory(furniture_type: String)
signal room_changed
signal movement_failed(reason: String)
signal npc_chat_message(sender: String, text: String)
signal furniture_selected(data: Dictionary)
signal furniture_deselected
signal placement_failed(reason: String)

const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")
const FurnitureRendererScript := preload("res://scripts/room/FurnitureRenderer.gd")
const RoomPathfinderScript := preload("res://scripts/room/RoomPathfinder.gd")
const NPCManagerScript := preload("res://scripts/data/NPCManager.gd")
const WallRendererScript := preload("res://scripts/room/WallRenderer.gd")
const FurnitureFootprintScript := preload("res://scripts/room/FurnitureFootprint.gd")
const FloorRendererScript := preload("res://scripts/room/FloorRenderer.gd")
const IsoGridScript := preload("res://scripts/room/IsoGrid.gd")
const FurniturePreviewScene := preload("res://scenes/room/FurniturePreview.tscn")
const TILE_WIDTH := 64
const TILE_HEIGHT := 32
const PLAYER_SCENE := preload("res://scenes/room/Player.tscn")
const NPC_SCENE := preload("res://scenes/room/NPC.tscn")

const VALID_FLOOR_TYPES := [
	"beige_basic", "beige_dark", "cream_basic", "brown_basic",
	"beige_border", "beige_diagonal", "beige_center", "beige_worn",
	"dark_tile", "blue_tile", "red_tile", "green_tile",
	"marble_tile", "wood_parquet", "checker_tile", "premium_gold_tile",
]

const VALID_WALL_TYPES := ["default", "trim", "dark", "pastel", "blue", "green", "red", "purple"]

var room_data := {}
var room_width := 10
var room_height := 10
var floor_type := "beige_basic"
var wall_type := "default"
var floor_renderer
var wall_renderer
var furniture_renderer
var player: Node2D
var furniture_list: Array = []
var selected_furniture_id := ""
var selected_catalog_type := ""
var decoration_mode := false
var current_profile := {}
var input_blocked := false
var current_path: Array[Vector2i] = []
var is_player_moving := false
var npc_list: Array = []
var npc_nodes: Dictionary = {}
var npc_move_timer: Timer
var npc_chat_timer: Timer
var npc_chat_to_panel := true
var npc_manager = NPCManagerScript.new()
# TODO: Save NPC custom positions if local visitors become persistent.
var preview_node: Node = null
var preview_furniture_type := ""
var preview_rotation := 0
var preview_cell := Vector2i.ZERO
var has_active_preview := false

@onready var floor_layer: Node2D = $FloorLayer
@onready var wall_layer: Node2D = $WallLayer
@onready var furniture_layer: Node2D = $FurnitureLayer
@onready var npc_layer: Node2D = $NPCLayer
@onready var player_layer: Node2D = $PlayerLayer


func _ready() -> void:
	if room_data.is_empty():
		room_data = {
			"id": "room_default",
			"name": "Mi Sala",
			"width": 10,
			"height": 10,
			"floor_type": "beige_basic",
			"wall_type": "default",
			"player_cell": { "x": 4, "y": 4 },
			"furniture": [],
		}
	setup(room_data)


func _unhandled_input(event: InputEvent) -> void:
	if input_blocked:
		return
	if decoration_mode and has_active_preview and event is InputEventMouseMotion:
		update_furniture_preview(get_local_mouse_position())
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell := IsoGridScript.world_to_grid(get_local_mouse_position(), TILE_WIDTH, TILE_HEIGHT)
		if not is_cell_inside_room(cell):
			return
		if decoration_mode:
			_handle_decoration_click(cell)
		else:
			move_player_to_cell(cell)
		get_viewport().set_input_as_handled()


func setup(data: Dictionary) -> void:
	room_data = data
	room_width = int(room_data.get("width", 10))
	room_height = int(room_data.get("height", 10))
	floor_type = sanitize_floor_type(String(room_data.get("floor_type", "beige_basic")))
	wall_type = sanitize_wall_type(String(room_data.get("wall_type", "default")))
	room_data["floor_type"] = floor_type
	room_data["wall_type"] = wall_type
	furniture_renderer = FurnitureRendererScript.new()
	furniture_renderer.setup(furniture_layer)
	furniture_list = _parse_furniture_save_list(room_data.get("furniture", []))
	redraw_room()
	spawn_player(_get_room_player_cell(room_data))


func redraw_room() -> void:
	redraw_floor()
	redraw_walls()
	redraw_furniture()


func redraw_floor() -> void:
	floor_renderer = FloorRendererScript.new(
		floor_layer,
		room_width,
		room_height,
		floor_type
	)
	floor_renderer.redraw()


func redraw_walls() -> void:
	wall_renderer = WallRendererScript.new(wall_layer, room_width, room_height, wall_type)
	wall_renderer.redraw()


func redraw_furniture() -> void:
	if not furniture_renderer:
		furniture_renderer = FurnitureRendererScript.new()
		furniture_renderer.setup(furniture_layer)
	furniture_renderer.redraw(furniture_list)


func spawn_player(cell: Vector2i) -> void:
	if player:
		player.queue_free()
	player = PLAYER_SCENE.instantiate()
	player_layer.add_child(player)
	player.move_finished.connect(_on_player_move_finished)
	player.set_cell(cell)
	if not current_profile.is_empty():
		player.apply_profile(current_profile)


func apply_profile(profile_data: Dictionary) -> void:
	current_profile = profile_data.duplicate(true)
	if player and player.has_method("apply_profile"):
		player.apply_profile(current_profile)


func show_player_speech(text: String) -> void:
	if player and player.has_method("show_speech"):
		player.show_speech(text)


func set_input_blocked(blocked: bool) -> void:
	input_blocked = blocked


func move_player_to_cell(cell: Vector2i) -> void:
	if input_blocked or decoration_mode or is_player_moving:
		return
	if not is_cell_inside_room(cell):
		movement_failed.emit("fuera")
		return
	if not player:
		spawn_player(cell)
		room_changed.emit()
		return
	if player.current_cell == cell:
		return
	var blocked_cells := get_dynamic_blocked_cells(false, true)
	if RoomPathfinderScript.is_blocked(cell, blocked_cells):
		movement_failed.emit("bloqueado")
		return
	var path: Array[Vector2i] = RoomPathfinderScript.find_path(
		player.current_cell,
		cell,
		Vector2i(room_width, room_height),
		blocked_cells
	)
	if path.is_empty():
		movement_failed.emit("sin_ruta")
		return
	start_player_path(path)


func set_decoration_mode(enabled: bool) -> void:
	decoration_mode = enabled
	if npc_move_timer:
		npc_move_timer.paused = enabled
	if npc_chat_timer:
		npc_chat_timer.paused = enabled
	if not decoration_mode:
		selected_catalog_type = ""
		cancel_furniture_preview()
		clear_furniture_selection()


func set_selected_catalog_type(furniture_type: String) -> void:
	start_furniture_preview(furniture_type)


func place_furniture(furniture_type: String, cell: Vector2i) -> void:
	if not can_place_furniture(furniture_type, cell):
		return
	furniture_place_requested.emit(furniture_type, cell, 0)


func confirm_place_furniture(furniture_type: String, cell: Vector2i, furniture_rotation: int = 0) -> bool:
	if not can_place_furniture(furniture_type, cell, furniture_rotation):
		placement_failed.emit("No se puede colocar aqui")
		return false
	var data := {
		"id": _make_furniture_id(),
		"type": furniture_type,
		"cell": cell,
		"size": FurnitureCatalogScript.get_size(furniture_type),
		"rotation": posmod(furniture_rotation, 4),
	}
	furniture_list.append(data)
	var item: Node = furniture_renderer.add_furniture(data)
	cancel_furniture_preview()
	select_furniture(String(data["id"]))
	if item:
		item.z_index = int(item.position.y)
	room_changed.emit()
	return true


func select_furniture_at_cell(cell: Vector2i) -> void:
	if not furniture_renderer:
		return
	var item: Node = furniture_renderer.get_furniture_at_cell(cell)
	if not item:
		clear_furniture_selection()
		return
	select_furniture(item.furniture_id)


func select_furniture(furniture_id: String) -> void:
	var data := _get_furniture_data(furniture_id)
	if data.is_empty():
		clear_furniture_selection()
		return
	selected_furniture_id = furniture_id
	selected_catalog_type = ""
	if furniture_renderer:
		furniture_renderer.select_furniture(selected_furniture_id)
	furniture_selected.emit(data.duplicate(true))


func clear_furniture_selection() -> void:
	selected_furniture_id = ""
	if furniture_renderer:
		furniture_renderer.clear_selection()
	furniture_deselected.emit()


func get_selected_furniture_data() -> Dictionary:
	var data := _get_furniture_data(selected_furniture_id)
	return data.duplicate(true)


func rotate_selected_furniture() -> void:
	if selected_furniture_id.is_empty():
		return
	var data := _get_furniture_data(selected_furniture_id)
	if data.is_empty():
		return
	var next_rotation := posmod(int(data.get("rotation", 0)) + 1, 4)
	if not _can_place_data(data, data.get("cell", Vector2i.ZERO), selected_furniture_id, next_rotation):
		placement_failed.emit("No se puede rotar aqui")
		return
	data["rotation"] = next_rotation
	redraw_furniture()
	furniture_renderer.select_furniture(selected_furniture_id)
	furniture_selected.emit(data.duplicate(true))
	room_changed.emit()


func delete_selected_furniture() -> void:
	if selected_furniture_id.is_empty():
		return
	var removed_type := ""
	for index in range(furniture_list.size() - 1, -1, -1):
		if String(furniture_list[index].get("id", "")) == selected_furniture_id:
			removed_type = String(furniture_list[index].get("type", ""))
			furniture_list.remove_at(index)
			break
	selected_furniture_id = ""
	redraw_furniture()
	if not removed_type.is_empty():
		furniture_removed_to_inventory.emit(removed_type)
	furniture_deselected.emit()
	room_changed.emit()


func get_room_state() -> Dictionary:
	return {
		"id": String(room_data.get("id", "room_default")),
		"name": String(room_data.get("name", "Mi Sala")),
		"width": room_width,
		"height": room_height,
		"floor_type": floor_type,
		"wall_type": wall_type,
		"player_cell": vector2i_to_dict(player.current_cell if player else Vector2i(4, 4)),
		"furniture": _get_furniture_save_list(),
	}


func load_room_state(saved_room: Dictionary) -> void:
	clear_npcs()
	room_data = {
		"id": String(saved_room.get("id", "room_default")),
		"name": String(saved_room.get("name", "Mi Sala")),
		"width": int(saved_room.get("width", 10)),
		"height": int(saved_room.get("height", 10)),
		"floor_type": String(saved_room.get("floor_type", "beige_basic")),
		"wall_type": String(saved_room.get("wall_type", "default")),
	}
	room_width = int(room_data.get("width", 10))
	room_height = int(room_data.get("height", 10))
	floor_type = sanitize_floor_type(String(saved_room.get("floor_type", "beige_basic")))
	wall_type = sanitize_wall_type(String(saved_room.get("wall_type", "default")))
	room_data["floor_type"] = floor_type
	room_data["wall_type"] = wall_type
	furniture_list = _parse_furniture_save_list(saved_room.get("furniture", []))
	selected_furniture_id = ""
	selected_catalog_type = ""

	if not furniture_renderer:
		furniture_renderer = FurnitureRendererScript.new()
		furniture_renderer.setup(furniture_layer)
	redraw_room()

	var player_cell := _get_room_player_cell(saved_room)
	spawn_player(player_cell)


func get_save_data() -> Dictionary:
	return {
		"version": 1,
		"room": {
			"id": String(room_data.get("id", "room_default")),
			"name": String(room_data.get("name", "Mi Sala")),
			"width": room_width,
			"height": room_height,
			"floor_type": floor_type,
			"wall_type": wall_type,
		},
		"player": {
			"cell": vector2i_to_dict(player.current_cell if player else Vector2i(4, 4)),
			"direction": player.current_direction if player else "south",
		},
		"furniture": _get_furniture_save_list(),
	}


func load_save_data(data: Dictionary) -> void:
	if data.has("rooms"):
		load_room_state(data.get("rooms", [])[0] if not data.get("rooms", []).is_empty() else {})
		return
	var old_room: Dictionary = data.get("room", {})
	old_room["player_cell"] = data.get("player", {}).get("cell", { "x": 4, "y": 4 })
	old_room["furniture"] = data.get("furniture", [])
	load_room_state(old_room)


func is_cell_inside_room(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < room_width and cell.y < room_height


func is_cell_walkable(cell: Vector2i) -> bool:
	return is_cell_inside_room(cell) and not get_dynamic_blocked_cells(false, true).has(cell)


func get_walkable_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(room_width):
		for y in range(room_height):
			var cell := Vector2i(x, y)
			if is_cell_walkable(cell):
				cells.append(cell)
	return cells


func get_blocked_cells() -> Dictionary:
	var blocked := {}
	for data in furniture_list:
		for occupied_cell in get_furniture_occupied_cells(data):
			blocked[occupied_cell] = true
	return blocked


func get_npc_cells() -> Dictionary:
	var cells := {}
	for npc_id in npc_nodes.keys():
		var npc: Node = npc_nodes[npc_id]
		if is_instance_valid(npc):
			cells[npc.current_cell] = String(npc_id)
	return cells


func is_cell_occupied_by_character(cell: Vector2i) -> bool:
	if player and player.current_cell == cell:
		return true
	return get_npc_cells().has(cell)


func get_dynamic_blocked_cells(include_player: bool = true, include_npcs: bool = true, ignored_npc_id: String = "") -> Dictionary:
	var blocked := get_blocked_cells()
	if include_player and player:
		blocked[player.current_cell] = true
	if include_npcs:
		for npc_id in npc_nodes.keys():
			if String(npc_id) == ignored_npc_id:
				continue
			var npc: Node = npc_nodes[npc_id]
			if is_instance_valid(npc):
				blocked[npc.current_cell] = true
	return blocked


func spawn_npcs(npcs: Array) -> void:
	clear_npcs()
	_ensure_npc_timers()
	for data in npcs:
		if typeof(data) != TYPE_DICTIONARY:
			continue
		var npc_data: Dictionary = data.duplicate(true)
		var npc_id := String(npc_data.get("id", "npc"))
		var cell := dict_to_vector2i(npc_data.get("cell", { "x": 0, "y": 0 }))
		if not is_cell_inside_room(cell) or get_dynamic_blocked_cells(true, true).has(cell):
			cell = _find_spawn_cell()
		npc_data["cell"] = vector2i_to_dict(cell)

		var npc: Node = NPC_SCENE.instantiate()
		npc_layer.add_child(npc)
		npc.setup(npc_data)
		npc.move_finished.connect(_on_npc_move_finished)
		npc_nodes[npc_id] = npc
		npc_list.append(npc_data)
	_start_npc_timers()


func clear_npcs() -> void:
	if npc_move_timer:
		npc_move_timer.stop()
	if npc_chat_timer:
		npc_chat_timer.stop()
	for npc in npc_nodes.values():
		if is_instance_valid(npc):
			npc.queue_free()
	npc_nodes.clear()
	npc_list.clear()


func move_random_npc() -> void:
	_schedule_npc_move()
	if npc_nodes.is_empty():
		return
	var ids := npc_nodes.keys()
	ids.shuffle()
	for npc_id in ids:
		var npc: Node = npc_nodes[npc_id]
		if not is_instance_valid(npc) or npc.is_moving:
			continue
		var candidates := _get_valid_npc_neighbors(npc.current_cell, String(npc_id))
		if candidates.is_empty():
			continue
		npc.move_to_cell(candidates.pick_random())
		return


func make_random_npc_chat() -> void:
	_schedule_npc_chat()
	if npc_nodes.is_empty():
		return
	var npc: Node = npc_nodes.values().pick_random()
	if not is_instance_valid(npc):
		return
	var text := npc_manager.get_random_chat_line()
	npc.show_speech(text)
	if npc_chat_to_panel:
		npc_chat_message.emit(npc.npc_name, text)


func get_furniture_occupied_cells(data: Dictionary) -> Array[Vector2i]:
	return _get_occupied_cells_for_data(data)


func vector2i_to_dict(v: Vector2i) -> Dictionary:
	return { "x": v.x, "y": v.y }


func dict_to_vector2i(data) -> Vector2i:
	if data is Vector2i:
		return data
	if data is Dictionary:
		return Vector2i(int(data.get("x", 0)), int(data.get("y", 0)))
	return Vector2i.ZERO


func set_floor_type(value: String) -> void:
	floor_type = sanitize_floor_type(value)
	room_data["floor_type"] = floor_type
	redraw_floor()
	room_changed.emit()


func get_floor_type() -> String:
	return floor_type


func sanitize_floor_type(value: String) -> String:
	return value if VALID_FLOOR_TYPES.has(value) else "beige_basic"


func set_wall_type(value: String) -> void:
	wall_type = sanitize_wall_type(value)
	room_data["wall_type"] = wall_type
	redraw_walls()
	room_changed.emit()


func get_wall_type() -> String:
	return wall_type


func sanitize_wall_type(value: String) -> String:
	return value if VALID_WALL_TYPES.has(value) else "default"


func _get_room_player_cell(data: Dictionary) -> Vector2i:
	if data.has("player_cell"):
		return dict_to_vector2i(data.get("player_cell", { "x": 4, "y": 4 }))
	if data.has("player_start") and data.get("player_start") is Vector2i:
		return data.get("player_start", Vector2i(4, 4))
	return Vector2i(4, 4)


func can_place_furniture(furniture_type: String, cell: Vector2i, furniture_rotation: int = 0, ignore_furniture_id: String = "") -> bool:
	var data := {
		"type": furniture_type,
		"cell": cell,
		"size": FurnitureCatalogScript.get_size(furniture_type),
		"rotation": furniture_rotation,
	}
	return _can_place_data(data, cell, ignore_furniture_id, furniture_rotation)


func _handle_decoration_click(cell: Vector2i) -> void:
	if furniture_renderer and furniture_renderer.get_furniture_at_cell(cell):
		select_furniture_at_cell(cell)
		return
	if has_active_preview:
		confirm_furniture_preview()
	else:
		clear_furniture_selection()


func start_furniture_preview(furniture_type: String) -> void:
	selected_catalog_type = furniture_type
	clear_furniture_selection()
	preview_furniture_type = furniture_type
	preview_rotation = 0
	has_active_preview = true
	if preview_node:
		preview_node.queue_free()
	preview_node = FurniturePreviewScene.instantiate()
	$SelectionLayer.add_child(preview_node)
	preview_node.setup(furniture_type, preview_rotation)
	update_furniture_preview(get_local_mouse_position())


func update_furniture_preview(mouse_world_pos: Vector2) -> void:
	if not has_active_preview or not preview_node:
		return
	preview_cell = IsoGridScript.world_to_grid(mouse_world_pos, TILE_WIDTH, TILE_HEIGHT)
	preview_node.set_cell(preview_cell)
	preview_node.set_valid(can_place_furniture(preview_furniture_type, preview_cell, preview_rotation))
	preview_node.show_preview()


func rotate_furniture_preview() -> void:
	if not has_active_preview or not preview_node:
		return
	preview_rotation = posmod(preview_rotation + 1, 4)
	preview_node.set_preview_rotation(preview_rotation)
	preview_node.set_valid(can_place_furniture(preview_furniture_type, preview_cell, preview_rotation))


func cancel_furniture_preview() -> void:
	selected_catalog_type = ""
	has_active_preview = false
	preview_furniture_type = ""
	if preview_node:
		preview_node.queue_free()
		preview_node = null


func confirm_furniture_preview() -> void:
	if not has_active_preview:
		return
	if not can_place_furniture(preview_furniture_type, preview_cell, preview_rotation):
		placement_failed.emit("No se puede colocar aqui")
		return
	furniture_place_requested.emit(preview_furniture_type, preview_cell, preview_rotation)


func start_player_path(path: Array[Vector2i]) -> void:
	if path.is_empty() or not player:
		return
	current_path = path.duplicate()
	move_player_next_step()


func move_player_next_step() -> void:
	if current_path.is_empty() or not player:
		is_player_moving = false
		room_changed.emit()
		return
	var next_cell: Vector2i = current_path.pop_front()
	if not is_cell_walkable(next_cell):
		current_path.clear()
		is_player_moving = false
		movement_failed.emit("bloqueado")
		return
	is_player_moving = true
	player.move_to_cell(next_cell)
	player_moved.emit(next_cell)


func _on_player_move_finished() -> void:
	is_player_moving = false
	if not current_path.is_empty():
		move_player_next_step()
	else:
		room_changed.emit()


func _can_place_data(data: Dictionary, target_cell: Vector2i, ignore_id: String = "", rotation_override: int = -1) -> bool:
	var furniture_type := String(data.get("type", "chair"))
	var size: Vector2i = data.get("size", FurnitureCatalogScript.get_size(furniture_type))
	var furniture_rotation := int(data.get("rotation", 0))
	if rotation_override >= 0:
		furniture_rotation = rotation_override
	var occupied_size := FurnitureFootprintScript.get_rotated_size(size, furniture_rotation)

	for x in range(occupied_size.x):
		for y in range(occupied_size.y):
			var occupied_cell := target_cell + Vector2i(x, y)
			if not is_cell_inside_room(occupied_cell):
				return false
			if _is_cell_occupied(occupied_cell, ignore_id):
				return false
			if player and player.current_cell == occupied_cell:
				return false
			if get_npc_cells().has(occupied_cell):
				return false
	return true


func _ensure_npc_timers() -> void:
	if not npc_move_timer:
		npc_move_timer = Timer.new()
		npc_move_timer.one_shot = false
		add_child(npc_move_timer)
		npc_move_timer.timeout.connect(move_random_npc)
	if not npc_chat_timer:
		npc_chat_timer = Timer.new()
		npc_chat_timer.one_shot = false
		add_child(npc_chat_timer)
		npc_chat_timer.timeout.connect(make_random_npc_chat)


func _start_npc_timers() -> void:
	if npc_nodes.is_empty():
		return
	_schedule_npc_move()
	_schedule_npc_chat()
	npc_move_timer.paused = decoration_mode
	npc_chat_timer.paused = decoration_mode


func _schedule_npc_move() -> void:
	if npc_move_timer:
		npc_move_timer.wait_time = randf_range(3.0, 6.0)
		npc_move_timer.start()


func _schedule_npc_chat() -> void:
	if npc_chat_timer:
		npc_chat_timer.wait_time = randf_range(6.0, 12.0)
		npc_chat_timer.start()


func _get_valid_npc_neighbors(cell: Vector2i, npc_id: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var blocked := get_dynamic_blocked_cells(true, true, npc_id)
	var steps := [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1),
	]
	for step in steps:
		var next_cell: Vector2i = cell + step
		if is_cell_inside_room(next_cell) and not blocked.has(next_cell):
			result.append(next_cell)
	return result


func _find_spawn_cell() -> Vector2i:
	var blocked := get_dynamic_blocked_cells(true, true)
	for x in range(room_width):
		for y in range(room_height):
			var cell := Vector2i(x, y)
			if not blocked.has(cell):
				return cell
	return Vector2i.ZERO


func _on_npc_move_finished(_npc_id: String) -> void:
	pass


func _is_cell_occupied(cell: Vector2i, ignore_id: String = "") -> bool:
	for data in furniture_list:
		if String(data.get("id", "")) == ignore_id:
			continue
		for occupied_cell in _get_occupied_cells_for_data(data):
			if occupied_cell == cell:
				return true
	return false


func _get_occupied_cells_for_data(data: Dictionary) -> Array[Vector2i]:
	var furniture_type := String(data.get("type", "chair"))
	var base_cell: Vector2i = data.get("cell", Vector2i.ZERO)
	var size: Vector2i = data.get("size", FurnitureCatalogScript.get_size(furniture_type))
	return FurnitureFootprintScript.get_occupied_cells(base_cell, size, int(data.get("rotation", 0)))


func _get_rotated_size(size: Vector2i, furniture_rotation: int) -> Vector2i:
	return FurnitureFootprintScript.get_rotated_size(size, furniture_rotation)


func _get_furniture_data(furniture_id: String) -> Dictionary:
	for data in furniture_list:
		if String(data.get("id", "")) == furniture_id:
			return data
	return {}


func _make_furniture_id() -> String:
	return "furniture_%s_%s" % [Time.get_ticks_msec(), furniture_list.size()]


func _get_furniture_save_list() -> Array:
	var result := []
	for data in furniture_list:
		var furniture_type := String(data.get("type", "chair"))
		result.append({
			"id": String(data.get("id", "")),
			"type": furniture_type,
			"cell": vector2i_to_dict(data.get("cell", Vector2i.ZERO)),
			"size": vector2i_to_dict(data.get("size", FurnitureCatalogScript.get_size(furniture_type))),
			"rotation": int(data.get("rotation", 0)),
		})
	return result


func _parse_furniture_save_list(saved_furniture: Array) -> Array:
	var result := []
	for entry in saved_furniture:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var furniture_type := String(entry.get("type", "chair"))
		result.append({
			"id": String(entry.get("id", _make_furniture_id())),
			"type": furniture_type,
			"cell": dict_to_vector2i(entry.get("cell", {})),
			"size": dict_to_vector2i(entry.get("size", vector2i_to_dict(FurnitureCatalogScript.get_size(furniture_type)))),
			"rotation": int(entry.get("rotation", 0)),
		})
	return result
