extends CanvasLayer

signal room_selected(room_id: String)
signal create_room_requested
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

var rooms: Array = []
var current_room_id := ""

@onready var root: Control = $Root
@onready var room_list: VBoxContainer = $Root/Card/Margin/VBox/RoomsScroll/RoomList


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style($Root/Card)
	hide_panel()


func show_with_rooms(next_rooms: Array, next_current_room_id: String) -> void:
	rooms = next_rooms.duplicate(true)
	current_room_id = next_current_room_id
	root.visible = true
	_render_rooms()


func update_rooms(next_rooms: Array, next_current_room_id: String) -> void:
	rooms = next_rooms.duplicate(true)
	current_room_id = next_current_room_id
	_render_rooms()


func hide_panel() -> void:
	root.visible = false


func _render_rooms() -> void:
	for child in room_list.get_children():
		child.queue_free()

	for room in rooms:
		if typeof(room) == TYPE_DICTIONARY:
			room_list.add_child(_build_room_row(room))


func _build_room_row(room: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(460, 54)
	UIThemeScript.apply_dark_panel_style(row)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	row.add_child(hbox)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(labels)

	var room_id := String(room.get("id", ""))
	var title := Label.new()
	title.text = "%s%s" % [String(room.get("name", "Sala")), " (actual)" if room_id == current_room_id else ""]
	UIThemeScript.apply_label(title)
	labels.add_child(title)

	var detail := Label.new()
	detail.text = "%sx%s - %s muebles" % [
		int(room.get("width", 10)),
		int(room.get("height", 10)),
		(room.get("furniture", []) as Array).size(),
	]
	UIThemeScript.apply_label(detail, true)
	labels.add_child(detail)

	var enter_button := Button.new()
	enter_button.text = "Entrar"
	enter_button.disabled = room_id == current_room_id
	UIThemeScript.apply_primary_button(enter_button)
	enter_button.pressed.connect(_on_enter_pressed.bind(room_id))
	hbox.add_child(enter_button)

	return row


func _on_enter_pressed(room_id: String) -> void:
	room_selected.emit(room_id)


func _on_create_button_pressed() -> void:
	create_room_requested.emit()


func _on_close_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
