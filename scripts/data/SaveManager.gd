class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://save.json"


static func save_game(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_warning("SaveManager: no se pudo abrir save para escritura: %s" % FileAccess.get_open_error())
		return

	var json := JSON.stringify(data, "\t")
	file.store_string(json)
	file.close()


static func load_game() -> Dictionary:
	if not has_save():
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_warning("SaveManager: no se pudo abrir save para lectura: %s" % FileAccess.get_open_error())
		return {}

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(content)
	if error != OK:
		push_warning("SaveManager: save corrupto o JSON invalido en linea %s: %s" % [json.get_error_line(), json.get_error_message()])
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_warning("SaveManager: save.json no contiene un Dictionary raiz.")
		return {}

	return migrate_save_data(json.data)


static func migrate_save_data(data: Dictionary) -> Dictionary:
	if data.has("rooms"):
		data["version"] = 2
		return data

	var room_data: Dictionary = data.get("room", {})
	var player_data: Dictionary = data.get("player", {})
	var migrated_room := {
		"id": String(room_data.get("id", "room_default")),
		"name": String(room_data.get("name", "Mi Sala")),
		"width": int(room_data.get("width", 10)),
		"height": int(room_data.get("height", 10)),
		"floor_type": String(room_data.get("floor_type", "beige_basic")),
		"wall_type": String(room_data.get("wall_type", "default")),
		"player_cell": player_data.get("cell", { "x": 4, "y": 4 }),
		"furniture": data.get("furniture", []),
	}

	var migrated := data.duplicate(true)
	migrated["version"] = 2
	migrated["current_room_id"] = String(migrated_room.get("id", "room_default"))
	migrated["rooms"] = [migrated_room]
	migrated.erase("room")
	migrated.erase("player")
	migrated.erase("furniture")
	return migrated


static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


static func delete_save() -> void:
	if not has_save():
		return
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if error != OK:
		push_warning("SaveManager: no se pudo borrar save: %s" % error)
