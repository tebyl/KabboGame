class_name ChatManager
extends RefCounted

const MAX_MESSAGES := 50
const MAX_TEXT_LENGTH := 120

var messages := []
var next_id := 1


func add_message(sender: String, text: String, message_type: String = "local") -> Dictionary:
	var clean_text := _sanitize_text(text)
	if clean_text.is_empty():
		return {}

	var message := {
		"id": "msg_%03d" % next_id,
		"sender": _sanitize_sender(sender),
		"text": clean_text,
		"timestamp": Time.get_unix_time_from_system(),
		"type": message_type if not message_type.strip_edges().is_empty() else "local",
	}
	next_id += 1
	messages.append(message)
	_trim_messages()
	return message.duplicate(true)


func get_messages() -> Array:
	return messages.duplicate(true)


func clear_messages() -> void:
	messages.clear()


func to_save_data() -> Array:
	return get_messages()


func load_save_data(data: Array) -> void:
	messages.clear()
	next_id = 1
	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var clean_text := _sanitize_text(String(entry.get("text", "")))
		if clean_text.is_empty():
			continue
		var message := {
			"id": String(entry.get("id", "msg_%03d" % next_id)),
			"sender": _sanitize_sender(String(entry.get("sender", "Invitado"))),
			"text": clean_text,
			"timestamp": int(entry.get("timestamp", 0)),
			"type": String(entry.get("type", "local")),
		}
		messages.append(message)
		next_id += 1
	_trim_messages()


func _sanitize_text(text: String) -> String:
	var clean_text := text.replace("\n", " ").replace("\r", " ").strip_edges()
	if clean_text.length() > MAX_TEXT_LENGTH:
		clean_text = clean_text.substr(0, MAX_TEXT_LENGTH)
	return clean_text


func _sanitize_sender(sender: String) -> String:
	var clean_sender := sender.replace("\n", " ").replace("\r", " ").strip_edges()
	return clean_sender if not clean_sender.is_empty() else "Invitado"


func _trim_messages() -> void:
	while messages.size() > MAX_MESSAGES:
		messages.remove_at(0)
