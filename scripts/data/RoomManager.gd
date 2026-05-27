class_name RoomManager
extends RefCounted

const PermissionManagerScript := preload("res://scripts/data/PermissionManager.gd")
const DefaultGameDataScript := preload("res://scripts/data/DefaultGameData.gd")
const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")

const VALID_FLOOR_TYPES := [
	"beige_basic", "beige_dark", "cream_basic", "brown_basic",
	"beige_border", "beige_diagonal", "beige_center", "beige_worn",
	"dark_tile", "blue_tile", "red_tile", "green_tile",
	"marble_tile", "wood_parquet", "checker_tile", "premium_gold_tile",
]

const VALID_WALL_TYPES := ["default", "trim", "dark", "pastel", "blue", "green", "red", "purple"]
const MIN_ROOM_SIZE := 6
const MAX_ROOM_SIZE := 16
const MAX_ROOM_NAME_LENGTH := 24
const MAX_ROOM_DESCRIPTION_LENGTH := 120
const VALID_ROOM_TYPES := ["social", "descanso", "juegos", "estudio", "coleccion", "creativo", "privado"]
const VALID_ROOM_MOODS := ["relajada", "fiesta", "conversacion", "decoracion", "privada", "exploracion"]

var rooms: Array = []
var current_room_id := "room_default"
var default_owner_name := "Invitado"
var visited_room_ids_this_session := {}
var current_profile_data := { "name": "Invitado" }


func setup(data: Dictionary, owner_name: String = "Invitado") -> void:
	set_default_owner_name(owner_name)
	set_profile_data({ "name": default_owner_name })
	load_save_data(data)


func set_profile_data(profile_data: Dictionary) -> void:
	current_profile_data = profile_data.duplicate(true) if typeof(profile_data) == TYPE_DICTIONARY else {}
	if String(current_profile_data.get("name", "")).strip_edges().is_empty():
		current_profile_data["name"] = default_owner_name
	_apply_effective_roles()


func set_default_owner_name(owner_name: String) -> void:
	default_owner_name = owner_name if not owner_name.strip_edges().is_empty() else "Invitado"


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
	return _normalize_room(DefaultGameDataScript.get_default_room_data(default_owner_name))


func create_room(name: String, width: int = 10, height: int = 10) -> Dictionary:
	return create_room_with_size(name, width, height)


func create_room_with_size(name: String, width: int, height: int) -> Dictionary:
	var room_size := sanitize_room_size(width, height)
	var now := _now_timestamp()
	return {
		"id": _make_unique_room_id(),
		"name": sanitize_room_name(name),
		"description": "",
		"owner_name": default_owner_name,
		"owner_id": "",
		"local_role": PermissionManagerScript.ROLE_OWNER,
		"room_type": "social",
		"mood": "relajada",
		"rating": _make_empty_rating(),
		"visits": 0,
		"visit_log": [],
		"created_at": now,
		"updated_at": now,
		"width": room_size.x,
		"height": room_size.y,
		"floor_type": "beige_basic",
		"wall_type": "default",
		"player_cell": _make_center_cell(room_size.x, room_size.y),
		"furniture": [],
	}


func rename_room(room_id: String, new_name: String) -> bool:
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) == room_id:
			rooms[index]["name"] = sanitize_room_name(new_name)
			rooms[index]["updated_at"] = _now_timestamp()
			return true
	return false


func duplicate_room(room_id: String) -> Dictionary:
	var source := get_room(room_id)
	if source.is_empty():
		return {}

	var copy := source.duplicate(true)
	copy["id"] = _make_unique_room_id()
	copy["name"] = sanitize_room_name("Copia de %s" % String(source.get("name", "Sala")))
	copy["local_role"] = PermissionManagerScript.ROLE_OWNER
	# TODO: decide if duplicated furniture should affect inventory economy.
	return _normalize_room(copy, false)


func can_delete_room(room_id: String) -> bool:
	return rooms.size() > 1 and not get_room(room_id).is_empty()


func export_room(room_id: String) -> Dictionary:
	return get_room(room_id)


func import_room(room_data: Dictionary) -> Dictionary:
	if typeof(room_data) != TYPE_DICTIONARY or room_data.is_empty():
		return {}

	var imported := _normalize_room(room_data, false)
	imported["id"] = _make_unique_room_id()
	imported["name"] = sanitize_room_name(String(imported.get("name", "Sala")))
	imported["local_role"] = PermissionManagerScript.ROLE_OWNER
	if String(imported.get("owner_name", "")).strip_edges().is_empty():
		imported["owner_name"] = default_owner_name
	# TODO: imported public rooms may load as visitor.
	return imported


func set_room_role(room_id: String, role: String) -> bool:
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) == room_id:
			rooms[index]["local_role"] = PermissionManagerScript.sanitize_role(role)
			rooms[index]["local_role"] = PermissionManagerScript.get_effective_role(current_profile_data, rooms[index])
			return true
	return false


func get_room_role(room_id: String) -> String:
	var room := get_room(room_id)
	return PermissionManagerScript.sanitize_role(String(room.get("local_role", PermissionManagerScript.ROLE_OWNER)))


func is_current_room_owner() -> bool:
	return get_current_room_role() == PermissionManagerScript.ROLE_OWNER


func get_current_room_role() -> String:
	return get_room_role(current_room_id)


func toggle_room_role(room_id: String) -> String:
	var current_role: String = get_room_role(room_id)
	var next_role: String = PermissionManagerScript.ROLE_VISITOR if current_role == PermissionManagerScript.ROLE_OWNER else PermissionManagerScript.ROLE_OWNER
	return next_role if set_room_role(room_id, next_role) else ""


func sanitize_room_name(name: String) -> String:
	var safe_name := name.strip_edges()
	if safe_name.is_empty():
		safe_name = "Nueva Sala"
	if safe_name.length() > MAX_ROOM_NAME_LENGTH:
		safe_name = safe_name.substr(0, MAX_ROOM_NAME_LENGTH)
	return safe_name


func sanitize_room_description(description: String) -> String:
	var safe_description := description.strip_edges()
	if safe_description.length() > MAX_ROOM_DESCRIPTION_LENGTH:
		safe_description = safe_description.substr(0, MAX_ROOM_DESCRIPTION_LENGTH)
	return safe_description


func sanitize_room_type(value: String) -> String:
	return value if VALID_ROOM_TYPES.has(value) else "social"


func sanitize_room_mood(value: String) -> String:
	return value if VALID_ROOM_MOODS.has(value) else "relajada"


func sanitize_room_size(width: int, height: int) -> Vector2i:
	return Vector2i(
		clampi(width, MIN_ROOM_SIZE, MAX_ROOM_SIZE),
		clampi(height, MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	)


func update_current_room(room_data: Dictionary) -> void:
	update_room(current_room_id, room_data)


func update_room(room_id: String, room_data: Dictionary) -> void:
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) == room_id:
			var next_room := _normalize_room(room_data)
			next_room["id"] = room_id
			var previous_updated_at := int(rooms[index].get("updated_at", 0))
			if _room_decor_state_changed(rooms[index], next_room):
				next_room["updated_at"] = _now_timestamp()
			elif previous_updated_at > 0:
				next_room["updated_at"] = previous_updated_at
			rooms[index] = next_room
			return


func update_room_profile(room_id: String, profile_data: Dictionary) -> bool:
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) != room_id:
			continue
		var room: Dictionary = rooms[index]
		room["name"] = sanitize_room_name(String(profile_data.get("name", room.get("name", "Sala"))))
		room["description"] = sanitize_room_description(String(profile_data.get("description", room.get("description", ""))))
		room["room_type"] = sanitize_room_type(String(profile_data.get("room_type", room.get("room_type", "social"))))
		room["mood"] = sanitize_room_mood(String(profile_data.get("mood", room.get("mood", "relajada"))))
		room["updated_at"] = _now_timestamp()
		rooms[index] = _normalize_room(room)
		return true
	return false


func get_room_profile(room_id: String) -> Dictionary:
	var room := get_room(room_id)
	if room.is_empty():
		return {}
	return {
		"name": String(room.get("name", "Sala")),
		"description": String(room.get("description", "")),
		"owner_name": String(room.get("owner_name", default_owner_name)),
		"room_type": String(room.get("room_type", "social")),
		"mood": String(room.get("mood", "relajada")),
		"rating": _normalize_rating(room.get("rating", {})),
		"visits": max(0, int(room.get("visits", 0))),
		"visit_log": _sanitize_visit_log(room.get("visit_log", [])),
		"created_at": max(0, int(room.get("created_at", 0))),
		"updated_at": max(0, int(room.get("updated_at", 0))),
	}


func increment_room_visits(room_id: String) -> void:
	if visited_room_ids_this_session.has(room_id):
		return
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) != room_id:
			continue
		rooms[index]["visits"] = max(0, int(rooms[index].get("visits", 0))) + 1
		rooms[index]["visit_log"] = _increment_visit_log(rooms[index].get("visit_log", []))
		visited_room_ids_this_session[room_id] = true
		return


func set_room_rating(room_id: String, rating: int) -> bool:
	return rate_room(room_id, rating, String(current_profile_data.get("name", "")))


func rate_room(room_id: String, value: int, voter_id: String = "") -> bool:
	var safe_rating := clampi(value, 1, 5)
	var safe_voter := voter_id.strip_edges()
	if safe_voter.is_empty():
		safe_voter = "local"
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) != room_id:
			continue
		var rating_data := _normalize_rating(rooms[index].get("rating", {}))
		var votes: Dictionary = rating_data.get("votes", {})
		votes[safe_voter] = safe_rating
		var total := 0
		for vote in votes.values():
			total += clampi(int(vote), 1, 5)
		var count := votes.size()
		rating_data["votes"] = votes
		rating_data["total"] = total
		rating_data["count"] = count
		rating_data["average"] = float(total) / float(count) if count > 0 else 0.0
		rooms[index]["rating"] = rating_data
		rooms[index]["updated_at"] = _now_timestamp()
		return true
	return false


func get_room_rating_summary(room_id: String) -> Dictionary:
	var room := get_room(room_id)
	return _normalize_rating(room.get("rating", {})) if not room.is_empty() else _make_empty_rating()


func touch_room_updated_at(room_id: String) -> void:
	for index in range(rooms.size()):
		if String(rooms[index].get("id", "")) == room_id:
			rooms[index]["updated_at"] = _now_timestamp()
			return


func delete_room(room_id: String) -> bool:
	if not can_delete_room(room_id):
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
	visited_room_ids_this_session.clear()
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


func _normalize_room(room_data: Dictionary, keep_id: bool = true) -> Dictionary:
	var room_size := sanitize_room_size(int(room_data.get("width", 10)), int(room_data.get("height", 10)))
	var width := room_size.x
	var height := room_size.y
	var furniture := _sanitize_furniture_list(room_data.get("furniture", []))
	var room_id := String(room_data.get("id", ""))
	var now := _now_timestamp()
	var created_at: int = max(0, int(room_data.get("created_at", now)))
	var updated_at: int = max(0, int(room_data.get("updated_at", now)))
	if room_id.is_empty() or not keep_id:
		room_id = _make_unique_room_id()
	if typeof(furniture) != TYPE_ARRAY:
		furniture = []
	return {
		"id": room_id,
		"name": sanitize_room_name(String(room_data.get("name", "Sala"))),
		"description": sanitize_room_description(String(room_data.get("description", ""))),
		"owner_name": String(room_data.get("owner_name", default_owner_name)),
		"owner_id": String(room_data.get("owner_id", "")),
		"local_role": PermissionManagerScript.get_effective_role(current_profile_data, room_data),
		"room_type": sanitize_room_type(String(room_data.get("room_type", "social"))),
		"mood": sanitize_room_mood(String(room_data.get("mood", "relajada"))),
		"rating": _normalize_rating(room_data.get("rating", {})),
		"visits": max(0, int(room_data.get("visits", 0))),
		"visit_log": _sanitize_visit_log(room_data.get("visit_log", [])),
		"created_at": created_at,
		"updated_at": updated_at,
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


func _make_unique_room_id() -> String:
	var attempt := "room_%s_%s" % [Time.get_ticks_msec(), randi()]
	var suffix := 1
	while not get_room(attempt).is_empty():
		attempt = "room_%s_%s_%s" % [Time.get_ticks_msec(), randi(), suffix]
		suffix += 1
	return attempt


func _now_timestamp() -> int:
	return int(Time.get_unix_time_from_system())


func _room_decor_state_changed(previous_room: Dictionary, next_room: Dictionary) -> bool:
	return (
		String(previous_room.get("floor_type", "")) != String(next_room.get("floor_type", ""))
		or String(previous_room.get("wall_type", "")) != String(next_room.get("wall_type", ""))
		or previous_room.get("furniture", []) != next_room.get("furniture", [])
	)


func _increment_visit_log(value) -> Array:
	var result := _sanitize_visit_log(value)
	var today := _today_key()
	for entry in result:
		if String(entry.get("date", "")) == today:
			entry["count"] = max(0, int(entry.get("count", 0))) + 1
			return result
	result.append({
		"date": today,
		"count": 1,
	})
	return result


func _sanitize_visit_log(value) -> Array:
	var result := []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var date := String(entry.get("date", "")).strip_edges()
		if date.is_empty():
			continue
		result.append({
			"date": date,
			"count": max(0, int(entry.get("count", 0))),
		})
	return result


func _today_key() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [
		int(datetime.get("year", 1970)),
		int(datetime.get("month", 1)),
		int(datetime.get("day", 1)),
	]


func _sanitize_furniture_list(value) -> Array:
	var result := []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var furniture_type := String(entry.get("type", "")).strip_edges()
		if furniture_type.is_empty():
			continue
		if FurnitureCatalogScript.get_item(furniture_type).is_empty():
			continue
		var cell = entry.get("cell", {})
		if not (cell is Dictionary or cell is Vector2i):
			continue
		result.append({
			"id": String(entry.get("id", "furniture_%s_%s" % [Time.get_ticks_msec(), result.size()])),
			"type": furniture_type,
			"cell": cell,
			"size": _vector2i_to_dict(FurnitureCatalogScript.get_size(furniture_type)),
			"rotation": int(entry.get("rotation", 0)),
		})
	return result


func _apply_effective_roles() -> void:
	for index in range(rooms.size()):
		rooms[index]["local_role"] = PermissionManagerScript.get_effective_role(current_profile_data, rooms[index])


func _make_empty_rating() -> Dictionary:
	return {
		"average": 0.0,
		"count": 0,
		"total": 0,
		"votes": {},
	}


func _normalize_rating(value) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		var votes := {}
		var source_votes = value.get("votes", {})
		if typeof(source_votes) == TYPE_DICTIONARY:
			for voter_id in source_votes.keys():
				var vote := clampi(int(source_votes[voter_id]), 1, 5)
				votes[String(voter_id)] = vote
		var total := 0
		for vote_value in votes.values():
			total += int(vote_value)
		var count := votes.size()
		if count == 0:
			total = max(0, int(value.get("total", 0)))
			count = max(0, int(value.get("count", 0)))
		return {
			"average": float(total) / float(count) if count > 0 else 0.0,
			"count": count,
			"total": total,
			"votes": votes,
		}
	var old_rating := clampi(int(value), 0, 5)
	var votes := {}
	if old_rating > 0:
		votes["legacy"] = old_rating
	return {
		"average": float(old_rating) if old_rating > 0 else 0.0,
		"count": 1 if old_rating > 0 else 0,
		"total": old_rating,
		"votes": votes,
	}


func _vector2i_to_dict(value: Vector2i) -> Dictionary:
	return { "x": value.x, "y": value.y }
