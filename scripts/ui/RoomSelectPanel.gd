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
const WINDOW_MIN_SIZE := Vector2(900, 560)
const WINDOW_PADDING := Vector2(80, 70)
const CARD_HEIGHT := 158
const THUMBNAIL_SIZE := Vector2(120, 90)
const COLOR_WINDOW_BG := Color(0.05, 0.09, 0.17, 0.98)
const COLOR_WINDOW_BORDER := Color(0.22, 0.62, 0.95, 1.0)
const COLOR_WINDOW_INNER := Color(0.10, 0.18, 0.32, 1.0)
const COLOR_CARD_BG := Color(0.06, 0.12, 0.22, 1.0)
const COLOR_CARD_BORDER := Color(0.20, 0.46, 0.78, 1.0)
const COLOR_CARD_ACCENT := Color(0.96, 0.78, 0.25, 1.0)
const COLOR_INPUT_BG := Color(0.04, 0.08, 0.14, 1.0)
const COLOR_INPUT_BORDER := Color(0.20, 0.42, 0.70, 1.0)
const COLOR_TEXT_PRIMARY := Color(0.95, 0.98, 1.0, 1.0)
const COLOR_TEXT_MUTED := Color(0.65, 0.74, 0.86, 1.0)
const COLOR_BADGE_BG := Color(0.12, 0.22, 0.36, 1.0)
const COLOR_BADGE_BORDER := Color(0.40, 0.62, 0.88, 1.0)
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
@onready var card: PanelContainer = $Root/Card
@onready var room_list: VBoxContainer = $Root/Card/Margin/VBox/RoomsScroll/RoomList
@onready var name_input: LineEdit = $Root/Card/Margin/VBox/CreateForm/NameInput
@onready var width_input: SpinBox = $Root/Card/Margin/VBox/CreateForm/WidthInput
@onready var height_input: SpinBox = $Root/Card/Margin/VBox/CreateForm/HeightInput
@onready var export_current_button: Button = $Root/Card/Margin/VBox/Actions/ExportCurrentButton
@onready var delete_confirm: ConfirmationDialog = $DeleteConfirm
@onready var search_input: LineEdit = $Root/Card/Margin/VBox/Filters/SearchInput
@onready var type_filter: OptionButton = $Root/Card/Margin/VBox/Filters/TypeFilter
@onready var mood_filter: OptionButton = $Root/Card/Margin/VBox/Filters/MoodFilter
@onready var rooms_scroll: ScrollContainer = $Root/Card/Margin/VBox/RoomsScroll


func _ready() -> void:
	$Root/Overlay.color = UIThemeScript.COLOR_OVERLAY
	_apply_window_style(card)
	_apply_static_styles()
	_populate_filter_options(type_filter, ROOM_TYPES)
	_populate_filter_options(mood_filter, ROOM_MOODS)
	root.resized.connect(_on_root_resized)
	_position_card()
	hide_panel()


func show_with_rooms(next_rooms: Array, next_current_room_id: String) -> void:
	rooms = next_rooms.duplicate(true)
	current_room_id = next_current_room_id
	root.visible = true
	_position_card()
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
	row.custom_minimum_size = Vector2(0, CARD_HEIGHT)
	var is_current := String(room.get("id", "")) == current_room_id
	_apply_card_style(row, is_current)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	row.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 14)
	vbox.add_child(top_row)

	var thumbnail := _build_room_thumbnail(room, is_current)
	top_row.add_child(thumbnail)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.add_theme_constant_override("separation", 4)
	top_row.add_child(labels)

	var room_id := String(room.get("id", ""))
	var role := PermissionManagerScript.sanitize_role(String(room.get("local_role", PermissionManagerScript.ROLE_OWNER)))
	var can_rename := PermissionManagerScript.can_rename_room(role)
	var can_duplicate := PermissionManagerScript.can_duplicate_room(role)
	var can_delete := PermissionManagerScript.can_delete_room(role)
	var can_export := PermissionManagerScript.can_export_room(role)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	labels.add_child(title_row)

	var title := Label.new()
	title.text = String(room.get("name", "Sala"))
	title.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	title.add_theme_font_size_override("font_size", 18)
	title_row.add_child(title)

	if is_current:
		var badge := _make_badge("Actual", COLOR_CARD_ACCENT)
		title_row.add_child(badge)

	var detail := Label.new()
	detail.text = "📐 %sx%s   🛋 %s   %s / %s" % [
		int(room.get("width", 10)),
		int(room.get("height", 10)),
		(room.get("furniture", []) as Array).size(),
		_format_room_type(String(room.get("room_type", "social"))),
		_format_room_mood(String(room.get("mood", "relajada"))),
	]
	detail.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	labels.add_child(detail)

	var role_detail := Label.new()
	role_detail.text = "%s - %s" % [
		String(room.get("owner_name", "Invitado")),
		"Dueño" if role == PermissionManagerScript.ROLE_OWNER else "Visitante",
	]
	role_detail.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
	labels.add_child(role_detail)

	var rename_row := HBoxContainer.new()
	rename_row.add_theme_constant_override("separation", 6)
	labels.add_child(rename_row)

	var rename_input := LineEdit.new()
	rename_input.text = String(room.get("name", "Sala"))
	rename_input.max_length = 24
	rename_input.custom_minimum_size = Vector2(210, 0)
	_apply_input_style(rename_input)
	rename_row.add_child(rename_input)

	var rename_button := _make_button("✎ Renombrar", "secondary")
	rename_button.disabled = not can_rename
	rename_button.pressed.connect(_on_rename_pressed.bind(room_id, rename_input))
	rename_row.add_child(rename_button)

	var right_panel := VBoxContainer.new()
	right_panel.add_theme_constant_override("separation", 8)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_row.add_child(right_panel)

	var enter_button := Button.new()
	enter_button.text = "Entrar"
	enter_button.disabled = room_id == current_room_id
	enter_button.custom_minimum_size = Vector2(140, 46)
	_apply_primary_big_button(enter_button)
	enter_button.pressed.connect(_on_enter_pressed.bind(room_id))
	right_panel.add_child(enter_button)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	vbox.add_child(actions)

	var duplicate_button := _make_button("⧉ Duplicar", "secondary")
	duplicate_button.disabled = not can_duplicate
	duplicate_button.pressed.connect(_on_duplicate_pressed.bind(room_id))
	actions.add_child(duplicate_button)

	var export_button := _make_button("⬆ Exportar", "secondary")
	export_button.disabled = not can_export
	export_button.pressed.connect(_on_export_pressed.bind(room_id))
	actions.add_child(export_button)

	var delete_button := _make_button("🗑 Borrar", "danger")
	delete_button.disabled = rooms.size() <= 1 or not can_delete
	delete_button.pressed.connect(_on_delete_pressed.bind(room_id))
	actions.add_child(delete_button)

	var toggle_role_button := _make_button("Rol: %s" % ["Visitante" if role == PermissionManagerScript.ROLE_OWNER else "Dueño"], "secondary")
	toggle_role_button.pressed.connect(_on_toggle_role_pressed.bind(room_id))
	actions.add_child(toggle_role_button)

	return row


func _apply_static_styles() -> void:
	var title_label: Label = $Root/Card/Margin/VBox/Header/Title
	title_label.text = "🏠  Mis salas"
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)

	var close_button: Button = $Root/Card/Margin/VBox/Header/CloseButton
	close_button.text = "Cerrar"
	_apply_danger_button(close_button)

	search_input.placeholder_text = "🔍 Buscar por sala o dueño"
	search_input.custom_minimum_size = Vector2(360, 0)
	_apply_input_style(search_input)
	type_filter.custom_minimum_size = Vector2(180, 0)
	mood_filter.custom_minimum_size = Vector2(180, 0)
	_apply_dropdown_style(type_filter)
	_apply_dropdown_style(mood_filter)
	UIThemeScript.apply_popup_menu_style(type_filter.get_popup())
	UIThemeScript.apply_popup_menu_style(mood_filter.get_popup())

	var create_button: Button = $Root/Card/Margin/VBox/CreateForm/CreateButton
	create_button.text = "+ Crear"
	create_button.custom_minimum_size = Vector2(120, 36)
	_apply_success_button(create_button)

	var import_button: Button = $Root/Card/Margin/VBox/Actions/ImportButton
	import_button.text = "⬇ Importar sala"
	import_button.custom_minimum_size = Vector2(220, 40)
	_apply_primary_button(import_button)

	export_current_button.text = "⬆ Exportar actual"
	export_current_button.custom_minimum_size = Vector2(220, 40)
	_apply_primary_button(export_current_button)

	_apply_input_style(name_input)
	_apply_spinbox_style(width_input)
	_apply_spinbox_style(height_input)

	name_input.text = "Nueva Sala"
	name_input.placeholder_text = "＋ Nueva sala"
	name_input.custom_minimum_size = Vector2(320, 0)
	name_input.max_length = 24
	width_input.min_value = 6
	width_input.max_value = 16
	width_input.value = 10
	height_input.min_value = 6
	height_input.max_value = 16
	height_input.value = 10
	_apply_scroll_style(rooms_scroll)
	room_list.add_theme_constant_override("separation", 12)


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
			_apply_danger_button(button)
		"success":
			_apply_success_button(button)
		_:
			_apply_secondary_button(button)
	return button


func _apply_window_style(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", _make_stylebox(COLOR_WINDOW_BG, 14, COLOR_WINDOW_BORDER, 2))


func _apply_card_style(panel: PanelContainer, is_current: bool) -> void:
	var border_color := COLOR_CARD_ACCENT if is_current else COLOR_CARD_BORDER
	panel.add_theme_stylebox_override("panel", _make_stylebox(COLOR_CARD_BG, 12, border_color, 2))


func _apply_primary_button(button: Button) -> void:
	_apply_button_style(button, UIThemeScript.COLOR_PRIMARY)


func _apply_secondary_button(button: Button) -> void:
	_apply_button_style(button, UIThemeScript.COLOR_SECONDARY)


func _apply_success_button(button: Button) -> void:
	_apply_button_style(button, UIThemeScript.COLOR_SUCCESS)


func _apply_danger_button(button: Button) -> void:
	_apply_button_style(button, UIThemeScript.COLOR_DANGER)


func _apply_primary_big_button(button: Button) -> void:
	_apply_primary_button(button)
	button.add_theme_font_size_override("font_size", 16)


func _apply_button_style(button: Button, color: Color) -> void:
	button.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	button.add_theme_stylebox_override("normal", _make_stylebox(color, 10, color.lightened(0.16), 1))
	button.add_theme_stylebox_override("hover", _make_stylebox(color.lightened(0.12), 10, color.lightened(0.22), 1))
	button.add_theme_stylebox_override("pressed", _make_stylebox(color.darkened(0.12), 10, color.lightened(0.1), 1))
	button.add_theme_stylebox_override("disabled", _make_stylebox(UIThemeScript.COLOR_SECONDARY.darkened(0.3), 10, UIThemeScript.COLOR_SECONDARY.darkened(0.1), 1))


func _apply_input_style(input: LineEdit) -> void:
	input.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	input.add_theme_color_override("font_placeholder_color", COLOR_TEXT_MUTED)
	input.add_theme_stylebox_override("normal", _make_stylebox(COLOR_INPUT_BG, 8, COLOR_INPUT_BORDER, 1))
	input.add_theme_stylebox_override("focus", _make_stylebox(COLOR_INPUT_BG.lightened(0.05), 8, COLOR_WINDOW_BORDER, 1))


func _apply_dropdown_style(dropdown: OptionButton) -> void:
	dropdown.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	dropdown.add_theme_stylebox_override("normal", _make_stylebox(COLOR_INPUT_BG, 8, COLOR_INPUT_BORDER, 1))
	dropdown.add_theme_stylebox_override("hover", _make_stylebox(COLOR_INPUT_BG.lightened(0.06), 8, COLOR_WINDOW_BORDER, 1))
	dropdown.add_theme_stylebox_override("pressed", _make_stylebox(COLOR_INPUT_BG.lightened(0.1), 8, COLOR_WINDOW_BORDER, 1))


func _apply_spinbox_style(spinbox: SpinBox) -> void:
	spinbox.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	spinbox.add_theme_stylebox_override("normal", _make_stylebox(COLOR_INPUT_BG, 8, COLOR_INPUT_BORDER, 1))
	spinbox.add_theme_stylebox_override("focus", _make_stylebox(COLOR_INPUT_BG.lightened(0.05), 8, COLOR_WINDOW_BORDER, 1))
	var line_edit := spinbox.get_line_edit()
	if line_edit:
		_apply_input_style(line_edit)


func _apply_scroll_style(scroll: ScrollContainer) -> void:
	scroll.add_theme_stylebox_override("panel", _make_stylebox(COLOR_WINDOW_INNER, 10, COLOR_WINDOW_BORDER.darkened(0.2), 1))


func _make_stylebox(color: Color, radius: int, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _make_badge(text: String, accent: Color) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.add_theme_stylebox_override("panel", _make_stylebox(COLOR_BADGE_BG, 8, accent, 1))
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", COLOR_TEXT_PRIMARY)
	badge.add_child(label)
	return badge


func _build_room_thumbnail(room: Dictionary, is_current: bool) -> PanelContainer:
	var frame := PanelContainer.new()
	frame.custom_minimum_size = THUMBNAIL_SIZE
	frame.add_theme_stylebox_override("panel", _make_stylebox(COLOR_WINDOW_INNER, 10, COLOR_CARD_ACCENT if is_current else COLOR_CARD_BORDER, 2))

	var art := Control.new()
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(art)

	var wall := Polygon2D.new()
	wall.polygon = PackedVector2Array([
		Vector2(18, 30),
		Vector2(60, 10),
		Vector2(102, 30),
		Vector2(60, 50),
	])
	wall.color = Color(0.08, 0.14, 0.24, 1.0)
	art.add_child(wall)

	var floor := Polygon2D.new()
	floor.polygon = PackedVector2Array([
		Vector2(18, 50),
		Vector2(60, 30),
		Vector2(102, 50),
		Vector2(60, 70),
	])
	floor.color = Color(0.12, 0.22, 0.32, 1.0)
	art.add_child(floor)

	var furniture_count := (room.get("furniture", []) as Array).size()
	if furniture_count > 0:
		var sofa := ColorRect.new()
		sofa.color = Color(0.22, 0.64, 0.82, 1.0)
		sofa.position = Vector2(32, 50)
		sofa.size = Vector2(22, 8)
		art.add_child(sofa)

		var plant := ColorRect.new()
		plant.color = Color(0.2, 0.78, 0.4, 1.0)
		plant.position = Vector2(66, 46)
		plant.size = Vector2(9, 12)
		art.add_child(plant)
	else:
		var empty_mark := Label.new()
		empty_mark.text = "Sala vacía"
		empty_mark.add_theme_color_override("font_color", COLOR_TEXT_MUTED)
		empty_mark.position = Vector2(10, 52)
		art.add_child(empty_mark)

	return frame


func _position_card() -> void:
	if not card:
		return

	card.set_anchors_preset(Control.PRESET_TOP_LEFT)

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	var max_width: float = maxf(0.0, viewport_size.x - WINDOW_PADDING.x)
	var max_height: float = maxf(0.0, viewport_size.y - WINDOW_PADDING.y)

	var target_size: Vector2 = Vector2(
		viewport_size.x * 0.88,
		viewport_size.y * 0.86
	)

	target_size.x = clampf(target_size.x, WINDOW_MIN_SIZE.x, max_width)
	target_size.y = clampf(target_size.y, WINDOW_MIN_SIZE.y, max_height)

	card.size = target_size
	card.position = (viewport_size - target_size) * 0.5


func _on_root_resized() -> void:
	_position_card()


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
