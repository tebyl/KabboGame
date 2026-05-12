extends CanvasLayer

const VERSION_PATH := "res://VERSION.txt"

@onready var title_label: Label = $Root/Card/Margin/VBox/Title
@onready var version_label: Label = $Root/Card/Margin/VBox/Version
@onready var message_label: Label = $Root/Card/Margin/VBox/Message


func _ready() -> void:
	title_label.text = "Cargando KabboLike..."
	version_label.text = _read_version_summary()
	message_label.text = "Preparando demo local"


func set_message(text: String) -> void:
	if is_node_ready():
		message_label.text = text


func _read_version_summary() -> String:
	if not FileAccess.file_exists(VERSION_PATH):
		return "Demo"
	var file := FileAccess.open(VERSION_PATH, FileAccess.READ)
	if not file:
		return "Demo"
	var version := ""
	var build := ""
	while not file.eof_reached():
		var line := file.get_line()
		if line.begins_with("Version:"):
			version = line.replace("Version:", "").strip_edges()
		elif line.begins_with("Build:"):
			build = line.replace("Build:", "").strip_edges()
	file.close()
	return "Version %s %s" % [version, build]
