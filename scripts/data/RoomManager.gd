class_name RoomManager
extends RefCounted

const VALID_FLOOR_TYPES := [
	"beige_basic", "beige_dark", "cream_basic", "brown_basic",
	"beige_border", "beige_diagonal", "beige_center", "beige_worn",
	"dark_tile", "blue_tile", "red_tile", "green_tile",
	"marble_tile", "wood_parquet", "checker_tile", "premium_gold_tile",
]

const VALID_WALL_TYPES := ["default", "trim", "dark", "pastel", "blue", "green", "red", "purple"]

var rooms: Array = []
var current_room_id := "room_default"


func setup(data: Dictionary) -> void:
	load_save_data(data)


func get_rooms() -> Array:
	return rooms.duplicate(true)


func get_current_room_id() -> String:
	return current_room_id


func set_current_room(room_id: String) -> bool:
	if get_room(room_id).is_empty():
		return false
	current_room_id = room_id
	return true


func get_current_room() -> Dictionary:
	var room := get_room(current_room_id)
	if room.is_empty() and not rooms.is_empty():
		current_room_id = String(rooms[0].get("id", "room_default"))
		room = rooms[0]
	return room.duplicate(true)


func get_room(room_id: String) -> Dictionary:
	for room in rooms:
		if String(room.get("id", "")) == room_id:
			return room.duplicate(true)
	return {}


func add_room(room_data: Dictionary) -> void:
	var next_room := _normalize_room(room_data)
	if get_room(String(next_room.get("id", ""))).is_empty():
		rooms.append(next_room)


func create_default_room() -> Dictionary:
	return {
		"id": "room_default",
		"name": "Mi Sala",
		"width": 10,
		"height": 10,
		"floor_type": "beige_basic",
		"wall_type": "default",
		"player_cell": { "x": 4, "y": 4 },
		"furniture": [],
	}


func create_room(name: String, width: int = 10, height: int = 10) -> Dictionary:
	var room_id := "room_%s" % Time.get_ticks_msec()
	var safe_width = max(1, width)
	var safe_height = max(1, height)
	return {
		"id": room_id,
		"name": name if not name.strip_edges().is_empty() else "Nueva Sala",
		"width": safe_width,
		"height": safe_height,
		"floor_type": "beige_basic",
		"wall_type": "default",
		"player_cell": _make_center_cell(safe_width, safe_height),
		"furniture": [],
	}


func update_current_room(room_data: Dictionary) -> void:
	update_room(current_room_id, room_data)


func update_room(room_id: String, room_data: Dictionary) -> void:
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) == room_id:
			var next_room := _normalize_room(room_data)
			next_room["id"] = room_id
			rooms[index] = next_room
			return


func delete_room(room_id: String) -> bool:
	if rooms.size() <= 1:
		return false
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) == room_id:
			rooms.remove_at(index)
			if current_room_id == room_id:
				current_room_id = String(rooms[0].get("id", "room_default"))
			return true
	return false


func to_save_data() -> Dictionary:
	_ensure_valid_state()
	return {
		"current_room_id": current_room_id,
		"rooms": get_rooms(),
	}


func load_save_data(data: Dictionary) -> void:
	rooms.clear()
	current_room_id = String(data.get("current_room_id", "room_default"))
	var saved_rooms = data.get("rooms", [])
	if typeof(saved_rooms) != TYPE_ARRAY:
		saved_rooms = []
	for room in saved_rooms:
		if typeof(room) == TYPE_DICTIONARY:
			rooms.append(_normalize_room(room))
	_ensure_valid_state()


func _ensure_valid_state() -> void:
	if rooms.is_empty():
		rooms.append(create_default_room())
	if get_room(current_room_id).is_empty():
		current_room_id = String(rooms[0].get("id", "room_default"))


func _normalize_room(room_data: Dictionary) -> Dictionary:
	var width = max(1, int(room_data.get("width", 10)))
	var height = max(1, int(room_data.get("height", 10)))
	var furniture = room_data.get("furniture", [])
	if typeof(furniture) != TYPE_ARRAY:
		furniture = []
	return {
		"id": String(room_data.get("id", "room_%s" % Time.get_ticks_msec())),
		"name": String(room_data.get("name", "Sala")),
		"width": width,
		"height": height,
		"floor_type": _sanitize_floor_type(String(room_data.get("floor_type", "beige_basic"))),
		"wall_type": _sanitize_wall_type(String(room_data.get("wall_type", "default"))),
		"player_cell": room_data.get("player_cell", _make_center_cell(width, height)),
		"furniture": furniture,
	}


func _sanitize_floor_type(value: String) -> String:
	return value if VALID_FLOOR_TYPES.has(value) else "beige_basic"


func _sanitize_wall_type(value: String) -> String:
	return value if VALID_WALL_TYPES.has(value) else "default"


func _make_center_cell(width: int, height: int) -> Dictionary:
	return { "x": int(width / 2), "y": int(height / 2) }
