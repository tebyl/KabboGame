class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://save.json"

static var last_load_had_corrupt_save := false
static var last_corrupt_backup_path := ""


static func save_game(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_warning("SaveManager: no se pudo abrir save para escritura: %s" % FileAccess.get_open_error())
		return

	var json := JSON.stringify(data, "\t")
	file.store_string(json)
	file.close()


static func load_game() -> Dictionary:
	last_load_had_corrupt_save = false
	last_corrupt_backup_path = ""
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
		backup_corrupt_save()
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_warning("SaveManager: save.json no contiene un Dictionary raiz.")
		backup_corrupt_save()
		return {}

	return migrate_save_data(json.data)


static func migrate_save_data(data: Dictionary) -> Dictionary:
	if data.has("rooms"):
		data["version"] = 2
		if not data.has("onboarding") or typeof(data.get("onboarding")) != TYPE_DICTIONARY:
			data["onboarding"] = {
				"completed": false,
				"current_step": "welcome",
			}
		if not data.has("progression") or typeof(data.get("progression")) != TYPE_DICTIONARY:
			data["progression"] = _default_progression()
		if not data.has("settings") or typeof(data.get("settings")) != TYPE_DICTIONARY:
			data["settings"] = _default_settings()
		return data

	var room_data: Dictionary = data.get("room", {})
	var player_data: Dictionary = data.get("player", {})
	var now := int(Time.get_unix_time_from_system())
	var migrated_room := {
		"id": String(room_data.get("id", "room_default")),
		"name": String(room_data.get("name", "Mi Sala")),
		"description": String(room_data.get("description", "")),
		"owner_name": String(room_data.get("owner_name", "Invitado")),
		"owner_id": String(room_data.get("owner_id", "")),
		"local_role": String(room_data.get("local_role", "owner")),
		"room_type": String(room_data.get("room_type", "social")),
		"mood": String(room_data.get("mood", "relajada")),
		"rating": room_data.get("rating", 0),
		"visits": int(room_data.get("visits", 0)),
		"visit_log": room_data.get("visit_log", []),
		"created_at": int(room_data.get("created_at", now)),
		"updated_at": int(room_data.get("updated_at", now)),
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
	if not migrated.has("onboarding") or typeof(migrated.get("onboarding")) != TYPE_DICTIONARY:
		migrated["onboarding"] = {
			"completed": false,
			"current_step": "welcome",
		}
	if not migrated.has("progression") or typeof(migrated.get("progression")) != TYPE_DICTIONARY:
		migrated["progression"] = _default_progression()
	if not migrated.has("settings") or typeof(migrated.get("settings")) != TYPE_DICTIONARY:
		migrated["settings"] = _default_settings()
	migrated.erase("room")
	migrated.erase("player")
	migrated.erase("furniture")
	return migrated


static func _default_progression() -> Dictionary:
	return {
		"missions": {},
		"achievements": {},
		"stats": {
			"furniture_placed": 0,
			"messages_sent": 0,
			"items_bought": 0,
			"rooms_created": 0,
			"floors_changed": 0,
			"walls_changed": 0,
			"profile_updates": 0,
			"coins_earned": 0,
			"coins_spent": 0,
			"shop_opened": 0,
			"inventory_opened": 0,
			"mission_rewards_claimed": 0,
		},
	}


static func _default_settings() -> Dictionary:
	return {
		"sfx_enabled": true,
		"sfx_volume": 0.8,
	}


static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


static func backup_corrupt_save() -> void:
	if not has_save():
		return
	var timestamp := Time.get_datetime_string_from_system(false, true).replace(":", "").replace("-", "").replace("T", "_")
	var backup_path := "user://save_corrupt_backup_%s.json" % timestamp
	var source := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not source:
		return
	var content := source.get_as_text()
	source.close()
	var backup := FileAccess.open(backup_path, FileAccess.WRITE)
	if not backup:
		return
	backup.store_string(content)
	backup.close()
	last_load_had_corrupt_save = true
	last_corrupt_backup_path = backup_path
	delete_save()


static func delete_save() -> void:
	if not has_save():
		return
	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if error != OK:
		push_warning("SaveManager: no se pudo borrar save: %s" % error)
