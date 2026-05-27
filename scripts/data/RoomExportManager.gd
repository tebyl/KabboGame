class_name RoomExportManager
extends RefCounted

const EXPORT_DIR := "user://exports"
const IMPORT_PATH := "user://imports/import_room.json"
const FORMAT := "kabbom_room"
const VERSION := 1


static func export_room_to_file(room_data: Dictionary) -> String:
	if room_data.is_empty():
		return ""

	var dir := DirAccess.open("user://")
	if not dir:
		return ""
	if not dir.dir_exists("exports"):
		var error := dir.make_dir("exports")
		if error != OK:
			return ""

	var room_name := sanitize_file_name(String(room_data.get("name", "room")))
	var timestamp := Time.get_datetime_string_from_system(false, true).replace(":", "")
	var file_path := "%s/room_%s_%s.json" % [EXPORT_DIR, room_name, timestamp]
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return ""

	file.store_string(JSON.stringify({
		"format": FORMAT,
		"version": VERSION,
		"room": room_data,
	}, "\t"))
	file.close()
	return file_path


static func import_room_from_file() -> Dictionary:
	if not FileAccess.file_exists(IMPORT_PATH):
		return {}

	var file := FileAccess.open(IMPORT_PATH, FileAccess.READ)
	if not file:
		return {}

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(content) != OK:
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		return {}
	if String(json.data.get("format", "")) != FORMAT:
		return {}
	if int(json.data.get("version", 0)) != VERSION:
		return {}
	if not json.data.has("room") or typeof(json.data.get("room")) != TYPE_DICTIONARY:
		return {}
	return json.data.get("room", {})


static func sanitize_file_name(name: String) -> String:
	var safe_name := name.strip_edges().to_lower()
	var result := ""
	for i in range(safe_name.length()):
		var c := safe_name[i]
		if c.is_valid_identifier() or c.is_valid_int() or c == "-":
			result += c
		elif c == " " or c == "_":
			result += "_"
	if result.is_empty():
		result = "room"
	return result.substr(0, 40)
