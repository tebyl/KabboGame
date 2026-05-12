extends CanvasLayer

signal room_selected(room_id: String)
signal create_room_requested(name: String, width: int, height: int)
signal rename_room_requested(room_id: String, new_name: String)
signal duplicate_room_requested(room_id: String)
signal delete_room_requested(room_id: String)
signal export_room_requested(room_id: String)
signal import_room_requested
signal toggle_room_role_requested(room_id: String)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const PermissionManagerScript := preload("res://scripts/data/PermissionManager.gd")
const ROOM_TYPES := [
	{ "value": "", "label": "Todos los tipos" },
	{ "value": "social", "label": "Social" },
	{ "value": "descanso", "label": "Descanso" },
	{ "value": "juegos", "label": "Juegos" },
	{ "value": "estudio", "label": "Estudio" },
	{ "value": "coleccion", "label": "Colección" },
	{ "value": "creativo", "label": "Creativo" },
	{ "value": "privado", "label": "Privado" },
]
const ROOM_MOODS := [
	{ "value": "", "label": "Todos los estados" },
	{ "value": "relajada", "label": "Relajada" },
	{ "value": "fiesta", "label": "Fiesta" },
	{ "value": "conversacion", "label": "Conversación" },
	{ "value": "decoracion", "label": "Decoración" },
	{ "value": "privada", "label": "Privada" },
	{ "value": "exploracion", "label": "Exploracion" },
]

var rooms: Array = []
var current_room_id := ""
var pending_delete_room_id := ""
var search_text := ""
var selected_room_type := ""
var selected_room_mood := ""

@onready var root: Control = $Root
@onready var room_list: VBoxContainer = $Root/Card/Margin/VBox/RoomsScroll/RoomList
@onready var name_input: LineEdit = $Root/Card/Margin/VBox/CreateForm/NameInput
@onready var width_input: SpinBox = $Root/Card/Margin/VBox/CreateForm/WidthInput
@onready var height_input: SpinBox = $Root/Card/Margin/VBox/CreateForm/HeightInput
@onready var export_current_button: Button = $Root/Card/Margin/VBox/Actions/ExportCurrentButton
@onready var delete_confirm: ConfirmationDialog = $DeleteConfirm
@onready var search_input: LineEdit = $Root/Card/Margin/VBox/Filters/SearchInput
@onready var type_filter: OptionButton = $Root/Card/Margin/VBox/Filters/TypeFilter
@onready var mood_filter: OptionButton = $Root/Card/Margin/VBox/Filters/MoodFilter


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	UIThemeScript.apply_panel_style($Root/Card)
	_apply_static_styles()
	_populate_filter_options(type_filter, ROOM_TYPES)
	_populate_filter_options(mood_filter, ROOM_MOODS)
	hide_panel()


func show_with_rooms(next_rooms: Array, next_current_room_id: String) -> void:
	rooms = next_rooms.duplicate(true)
	current_room_id = next_current_room_id
	root.visible = true
	export_current_button.disabled = current_room_id.is_empty() or not PermissionManagerScript.can_export_room(_get_room_role(current_room_id))
	_render_rooms()


func update_rooms(next_rooms: Array, next_current_room_id: String) -> void:
	rooms = next_rooms.duplicate(true)
	current_room_id = next_current_room_id
	export_current_button.disabled = current_room_id.is_empty() or not PermissionManagerScript.can_export_room(_get_room_role(current_room_id))
	_render_rooms()


func hide_panel() -> void:
	root.visible = false


func _render_rooms() -> void:
	for child in room_list.get_children():
		child.queue_free()

	for room in rooms:
		if typeof(room) == TYPE_DICTIONARY:
			if _matches_filters(room):
				room_list.add_child(_build_room_row(room))


func _build_room_row(room: Dictionary) -> PanelContainer:
	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(620, 76)
	UIThemeScript.apply_dark_panel_style(row)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	row.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	vbox.add_child(top_row)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(labels)

	var room_id := String(room.get("id", ""))
	var role := PermissionManagerScript.sanitize_role(String(room.get("local_role", PermissionManagerScript.ROLE_OWNER)))
	var can_rename := PermissionManagerScript.can_rename_room(role)
	var can_duplicate := PermissionManagerScript.can_duplicate_room(role)
	var can_delete := PermissionManagerScript.can_delete_room(role)
	var can_export := PermissionManagerScript.can_export_room(role)
	var title := Label.new()
	title.text = "%s%s" % [String(room.get("name", "Sala")), " - Actual" if room_id == current_room_id else ""]
	UIThemeScript.apply_label(title)
	labels.add_child(title)

	var detail := Label.new()
	detail.text = "%sx%s - %s muebles - %s / %s" % [
		int(room.get("width", 10)),
		int(room.get("height", 10)),
		(room.get("furniture", []) as Array).size(),
		_format_room_type(String(room.get("room_type", "social"))),
		_format_room_mood(String(room.get("mood", "relajada"))),
	]
	UIThemeScript.apply_label(detail, true)
	labels.add_child(detail)

	var role_detail := Label.new()
	role_detail.text = "%s - %s" % [
		String(room.get("owner_name", "Invitado")),
		"Dueño" if role == PermissionManagerScript.ROLE_OWNER else "Visitante",
	]
	UIThemeScript.apply_label(role_detail, true)
	labels.add_child(role_detail)

	var enter_button := Button.new()
	enter_button.text = "Entrar"
	enter_button.disabled = room_id == current_room_id
	UIThemeScript.apply_primary_button(enter_button)
	enter_button.pressed.connect(_on_enter_pressed.bind(room_id))
	top_row.add_child(enter_button)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	vbox.add_child(actions)

	var rename_input := LineEdit.new()
	rename_input.text = String(room.get("name", "Sala"))
	rename_input.max_length = 24
	rename_input.custom_minimum_size = Vector2(150, 0)
	actions.add_child(rename_input)

	var rename_button := _make_button("Renombrar", "secondary")
	rename_button.disabled = not can_rename
	rename_button.pressed.connect(_on_rename_pressed.bind(room_id, rename_input))
	actions.add_child(rename_button)

	var duplicate_button := _make_button("Duplicar", "secondary")
	duplicate_button.disabled = not can_duplicate
	duplicate_button.pressed.connect(_on_duplicate_pressed.bind(room_id))
	actions.add_child(duplicate_button)

	var export_button := _make_button("Exportar", "secondary")
	export_button.disabled = not can_export
	export_button.pressed.connect(_on_export_pressed.bind(room_id))
	actions.add_child(export_button)

	var delete_button := _make_button("Borrar", "danger")
	delete_button.disabled = rooms.size() <= 1 or not can_delete
	delete_button.pressed.connect(_on_delete_pressed.bind(room_id))
	actions.add_child(delete_button)

	var toggle_role_button := _make_button("Rol: %s" % ["Visitante" if role == PermissionManagerScript.ROLE_OWNER else "Dueño"], "secondary")
	toggle_role_button.pressed.connect(_on_toggle_role_pressed.bind(room_id))
	actions.add_child(toggle_role_button)

	return row


func _apply_static_styles() -> void:
	UIThemeScript.apply_label($Root/Card/Margin/VBox/Header/Title)
	UIThemeScript.apply_secondary_button($Root/Card/Margin/VBox/Header/CloseButton)
	UIThemeScript.apply_success_button($Root/Card/Margin/VBox/CreateForm/CreateButton)
	UIThemeScript.apply_secondary_button($Root/Card/Margin/VBox/Actions/ImportButton)
	UIThemeScript.apply_secondary_button(export_current_button)
	name_input.max_length = 24
	width_input.min_value = 6
	width_input.max_value = 16
	width_input.value = 10
	height_input.min_value = 6
	height_input.max_value = 16
	height_input.value = 10


func _populate_filter_options(option: OptionButton, values: Array) -> void:
	option.clear()
	for index in range(values.size()):
		var entry: Dictionary = values[index]
		option.add_item(String(entry.get("label", "")), index)


func _matches_filters(room: Dictionary) -> bool:
	var normalized_search := search_text.strip_edges().to_lower()
	if not normalized_search.is_empty():
		var haystack := "%s %s" % [
			String(room.get("name", "")).to_lower(),
			String(room.get("owner_name", "")).to_lower(),
		]
		if not haystack.contains(normalized_search):
			return false
	if not selected_room_type.is_empty() and String(room.get("room_type", "")) != selected_room_type:
		return false
	if not selected_room_mood.is_empty() and String(room.get("mood", "")) != selected_room_mood:
		return false
	return true


func _make_button(text: String, kind: String) -> Button:
	var button := Button.new()
	button.text = text
	match kind:
		"danger":
			UIThemeScript.apply_danger_button(button)
		"success":
			UIThemeScript.apply_success_button(button)
		_:
			UIThemeScript.apply_secondary_button(button)
	return button


func _get_room_role(room_id: String) -> String:
	for room in rooms:
		if typeof(room) == TYPE_DICTIONARY and String(room.get("id", "")) == room_id:
			return PermissionManagerScript.sanitize_role(String(room.get("local_role", PermissionManagerScript.ROLE_OWNER)))
	return PermissionManagerScript.ROLE_VISITOR


func _format_room_type(room_type: String) -> String:
	for entry in ROOM_TYPES:
		if String(entry.get("value", "")) == room_type:
			return String(entry.get("label", "Social"))
	return "Social"


func _format_room_mood(mood: String) -> String:
	for entry in ROOM_MOODS:
		if String(entry.get("value", "")) == mood:
			return String(entry.get("label", "Relajada"))
	return "Relajada"


func _on_enter_pressed(room_id: String) -> void:
	room_selected.emit(room_id)


func _on_create_button_pressed() -> void:
	create_room_requested.emit(name_input.text, int(width_input.value), int(height_input.value))
	name_input.text = "Nueva Sala"
	width_input.value = 10
	height_input.value = 10


func _on_rename_pressed(room_id: String, input: LineEdit) -> void:
	rename_room_requested.emit(room_id, input.text)


func _on_duplicate_pressed(room_id: String) -> void:
	duplicate_room_requested.emit(room_id)


func _on_delete_pressed(room_id: String) -> void:
	pending_delete_room_id = room_id
	delete_confirm.popup_centered()


func _on_export_pressed(room_id: String) -> void:
	export_room_requested.emit(room_id)


func _on_import_button_pressed() -> void:
	import_room_requested.emit()


func _on_toggle_role_pressed(room_id: String) -> void:
	toggle_room_role_requested.emit(room_id)


func _on_export_current_button_pressed() -> void:
	if not current_room_id.is_empty():
		export_room_requested.emit(current_room_id)


func _on_delete_confirm_confirmed() -> void:
	if pending_delete_room_id.is_empty():
		return
	delete_room_requested.emit(pending_delete_room_id)
	pending_delete_room_id = ""


func _on_search_changed(next_text: String) -> void:
	search_text = next_text
	_render_rooms()


func _on_type_filter_selected(index: int) -> void:
	var entry: Dictionary = ROOM_TYPES[clampi(index, 0, ROOM_TYPES.size() - 1)]
	selected_room_type = String(entry.get("value", ""))
	_render_rooms()


func _on_mood_filter_selected(index: int) -> void:
	var entry: Dictionary = ROOM_MOODS[clampi(index, 0, ROOM_MOODS.size() - 1)]
	selected_room_mood = String(entry.get("value", ""))
	_render_rooms()


func _on_close_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
