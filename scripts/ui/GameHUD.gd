extends CanvasLayer

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const PermissionManagerScript := preload("res://scripts/data/PermissionManager.gd")
const DebugConfigScript := preload("res://scripts/data/DebugConfig.gd")
const VERSION_PATH := "res://VERSION.txt"
const COLOR_HUD_BG := Color(0.02, 0.20, 0.42, 0.98)
const COLOR_HUD_BG_DARK := Color(0.02, 0.08, 0.16, 0.98)
const COLOR_HUD_BORDER := Color(0.12, 0.78, 1.0, 1.0)
const COLOR_HUD_BUTTON := Color(0.02, 0.18, 0.34, 1.0)
const COLOR_HUD_BUTTON_HOT := Color(0.03, 0.47, 0.86, 1.0)
const COLOR_HUD_GOLD := Color(1.0, 0.74, 0.16, 1.0)
const COLOR_HUD_TEXT := Color(0.96, 0.98, 1.0, 1.0)
const COLOR_HUD_MUTED := Color(0.66, 0.78, 0.90, 1.0)

signal decorate_toggled(enabled: bool)
signal rotate_selected_requested
signal delete_selected_requested
signal inventory_requested
signal save_requested
signal profile_requested
signal shop_requested
signal rooms_requested
signal tutorial_requested
signal missions_requested
signal achievements_requested
signal settings_requested
signal decor_tools_requested
signal npc_manager_requested
signal room_info_requested
signal reset_progress_requested
signal exit_requested

@onready var room_name_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/RoomName
@onready var role_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/RoleLabel
@onready var coins_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/CoinsLabel
@onready var missions_button: Button = $Root/TopBar/MarginContainer/HBoxContainer/MissionsButton
@onready var decorate_button: Button = $Root/TopBar/MarginContainer/HBoxContainer/DecorateButton
@onready var rotate_button: Button = $Root/TopBar/MarginContainer/HBoxContainer/RotateButton
@onready var delete_button: Button = $Root/TopBar/MarginContainer/HBoxContainer/DeleteButton
@onready var menu_button: MenuButton = $Root/TopBar/MarginContainer/HBoxContainer/MenuButton
@onready var top_bar: PanelContainer = $Root/TopBar
@onready var help_text: Label = $Root/HelpText
@onready var saved_label: Label = $Root/SavedLabel
@onready var message_label: Label = $Root/MessageLabel


func _ready() -> void:
	_apply_styles()
	_setup_menu()
	decorate_button.toggled.connect(_on_decorate_toggled)


func setup(room_data: Dictionary) -> void:
	if not is_node_ready():
		await ready
	set_room_name(String(room_data.get("name", "Mi Sala")))


func set_room_name(room_name: String) -> void:
	if not is_node_ready():
		await ready
	room_name_label.text = room_name


func set_player_name(player_name: String) -> void:
	if not is_node_ready():
		await ready
	menu_button.tooltip_text = player_name


func set_coins(value: int) -> void:
	if not is_node_ready():
		await ready
	coins_label.text = "Monedas: %s" % value


func set_claimable_missions_count(count: int) -> void:
	if not is_node_ready():
		await ready
	missions_button.text = "Misiones" if count <= 0 else "Misiones (%s)" % count


func set_decorate_enabled(enabled: bool) -> void:
	if enabled and decorate_button.disabled:
		enabled = false
	decorate_button.set_pressed_no_signal(enabled)
	decorate_button.text = "Decora ON" if enabled else "Decora"
	help_text.text = "Selecciona o coloca muebles" if enabled else "Click para caminar"
	_apply_decorate_button_state(enabled)


func set_decoration_enabled(enabled: bool) -> void:
	set_decorate_enabled(enabled)


func set_room_role(role: String) -> void:
	if not is_node_ready():
		await ready
	var safe_role := PermissionManagerScript.sanitize_role(role)
	role_label.text = "Dueño" if safe_role == PermissionManagerScript.ROLE_OWNER else "Visitante"


func set_decorate_available(available: bool) -> void:
	if not is_node_ready():
		await ready
	decorate_button.disabled = not available
	if not available:
		set_decorate_enabled(false)


func _on_decorate_toggled(enabled: bool) -> void:
	if enabled and decorate_button.disabled:
		set_decorate_enabled(false)
		decorate_toggled.emit(false)
		return
	set_decorate_enabled(enabled)
	decorate_toggled.emit(enabled)


func _on_rotate_button_pressed() -> void:
	rotate_selected_requested.emit()


func _on_delete_button_pressed() -> void:
	delete_selected_requested.emit()


func _on_inventory_button_pressed() -> void:
	inventory_requested.emit()


func _on_save_button_pressed() -> void:
	save_requested.emit()


func _on_profile_button_pressed() -> void:
	profile_requested.emit()


func _on_shop_button_pressed() -> void:
	shop_requested.emit()


func _on_rooms_button_pressed() -> void:
	rooms_requested.emit()


func _on_tutorial_button_pressed() -> void:
	tutorial_requested.emit()


func _on_missions_button_pressed() -> void:
	missions_requested.emit()


func _on_achievements_button_pressed() -> void:
	achievements_requested.emit()


func _on_settings_button_pressed() -> void:
	settings_requested.emit()


func _setup_menu() -> void:
	var popup := menu_button.get_popup()
	popup.clear()
	_apply_premium_popup_style(popup)
	popup.add_item("Información de sala", 1)
	popup.add_item("Editar sala", 2)
	popup.add_item("Misiones", 3)
	popup.add_item("Logros", 4)
	popup.add_separator()
	popup.add_item("Guardar", 5)
	popup.add_item("Perfil", 6)
	popup.add_item("Tienda", 7)
	popup.add_item("Salas", 8)
	popup.add_item("NPCs", 9)
	popup.add_item("Audio", 10)
	popup.add_separator()
	popup.add_item("Reiniciar tutorial", 11)
	popup.add_item("Resetear progreso local", 12)
	popup.add_item("Salir", 13)
	if DebugConfigScript.SHOW_VERSION:
		popup.add_separator()
		popup.add_item(_get_version_summary(), 100)
		popup.set_item_disabled(popup.item_count - 1, true)
	popup.id_pressed.connect(_on_menu_id_pressed)


func _on_menu_id_pressed(id: int) -> void:
	match id:
		1:
			room_info_requested.emit()
		2:
			decor_tools_requested.emit()
		3:
			missions_requested.emit()
		4:
			achievements_requested.emit()
		5:
			save_requested.emit()
		6:
			profile_requested.emit()
		7:
			shop_requested.emit()
		8:
			rooms_requested.emit()
		9:
			npc_manager_requested.emit()
		10:
			settings_requested.emit()
		11:
			tutorial_requested.emit()
		12:
			reset_progress_requested.emit()
		13:
			exit_requested.emit()


func _get_version_summary() -> String:
	if not FileAccess.file_exists(VERSION_PATH):
		return "KabboLike Demo"
	var file := FileAccess.open(VERSION_PATH, FileAccess.READ)
	if not file:
		return "KabboLike Demo"
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


func show_saved_message() -> void:
	if not is_node_ready():
		await ready
	saved_label.visible = true
	await get_tree().create_timer(1.2).timeout
	saved_label.visible = false


func show_message(text: String) -> void:
	if not is_node_ready():
		await ready
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(1.6).timeout
	message_label.visible = false


func _apply_styles() -> void:
	_apply_premium_top_bar()
	for label in [room_name_label, role_label, coins_label, help_text, saved_label, message_label]:
		_apply_premium_label(label)
	_style_header_label(room_name_label)
	_style_badge_label(role_label, COLOR_HUD_GOLD)
	_style_badge_label(coins_label, COLOR_HUD_GOLD)
	for button in $Root/TopBar/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			_style_premium_button(button, COLOR_HUD_BUTTON)
	menu_button.text = "Menú"
	decorate_button.text = "Decora"
	_style_premium_button(menu_button, COLOR_HUD_BUTTON, "blue")
	_style_premium_button(decorate_button, COLOR_HUD_BUTTON_HOT, "cyan")
	UIThemeScript.apply_button_icon(menu_button, "menu")
	UIThemeScript.apply_button_icon(decorate_button, "decorate")
	if has_node("Root/TopBar/MarginContainer/HBoxContainer/InventoryButton"):
		var inventory_button: Button = $Root/TopBar/MarginContainer/HBoxContainer/InventoryButton
		inventory_button.text = "Inventario"
		_style_premium_button(inventory_button, Color(0.05, 0.28, 0.52, 1.0), "blue")
		UIThemeScript.apply_button_icon(inventory_button, "inventory")
	help_text.add_theme_color_override("font_color", COLOR_HUD_MUTED)
	saved_label.add_theme_color_override("font_color", Color(0.65, 1.0, 0.76, 1.0))
	message_label.add_theme_color_override("font_color", COLOR_HUD_TEXT)


func _apply_premium_top_bar() -> void:
	top_bar.custom_minimum_size = Vector2(0, 68)
	top_bar.offset_bottom = 68.0
	top_bar.add_theme_stylebox_override("panel", _make_premium_stylebox(COLOR_HUD_BG, 2, COLOR_HUD_BORDER, 3))
	UIThemeScript.apply_texture_panel_style(top_bar, "panel_blue_9slice", 8)
	var margin: MarginContainer = $Root/TopBar/MarginContainer
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 9)
	var row: HBoxContainer = $Root/TopBar/MarginContainer/HBoxContainer
	row.add_theme_constant_override("separation", 12)


func _apply_premium_label(label: Label) -> void:
	label.add_theme_color_override("font_color", COLOR_HUD_TEXT)
	label.add_theme_font_size_override("font_size", 17)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _style_header_label(label: Label) -> void:
	label.custom_minimum_size = Vector2(260, 46)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", COLOR_HUD_TEXT)


func _style_badge_label(label: Label, accent: Color) -> void:
	label.custom_minimum_size = Vector2(132, 42)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_stylebox_override("normal", _make_premium_stylebox(COLOR_HUD_BUTTON, 2, accent, 2))


func _style_premium_button(button: Button, color: Color, texture_variant: String = "blue") -> void:
	button.custom_minimum_size = Vector2(maxf(button.custom_minimum_size.x, 118.0), 42)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", COLOR_HUD_TEXT)
	button.add_theme_color_override("font_disabled_color", COLOR_HUD_MUTED)
	button.add_theme_stylebox_override("normal", _make_premium_stylebox(color, 2, COLOR_HUD_BORDER, 2))
	button.add_theme_stylebox_override("hover", _make_premium_stylebox(color.lightened(0.12), 2, COLOR_HUD_GOLD, 2))
	button.add_theme_stylebox_override("pressed", _make_premium_stylebox(color.darkened(0.10), 2, COLOR_HUD_BORDER.darkened(0.10), 2))
	button.add_theme_stylebox_override("disabled", _make_premium_stylebox(COLOR_HUD_BUTTON.darkened(0.26), 2, COLOR_HUD_BORDER.darkened(0.35), 1))
	UIThemeScript.apply_texture_button_style(button, texture_variant, 8)


func _apply_decorate_button_state(enabled: bool) -> void:
	if enabled:
		_style_premium_button(decorate_button, Color(0.05, 0.62, 0.95, 1.0), "cyan")
	else:
		_style_premium_button(decorate_button, COLOR_HUD_BUTTON_HOT, "cyan")


func _apply_premium_popup_style(popup: PopupMenu) -> void:
	popup.min_size = Vector2i(300, 0)
	popup.add_theme_stylebox_override("panel", _make_premium_stylebox(COLOR_HUD_BG_DARK, 2, COLOR_HUD_BORDER, 3))
	var popup_panel_texture := UIThemeScript.load_ui_texture("res://assets/ui/panels/panel_dark_9slice.png")
	if popup_panel_texture:
		popup.add_theme_stylebox_override("panel", UIThemeScript.make_texture_style(popup_panel_texture, 8))
	popup.add_theme_stylebox_override("hover", _make_premium_stylebox(COLOR_HUD_BUTTON_HOT.darkened(0.12), 2, COLOR_HUD_GOLD, 1))
	popup.add_theme_color_override("font_color", COLOR_HUD_TEXT)
	popup.add_theme_color_override("font_hover_color", COLOR_HUD_TEXT)
	popup.add_theme_color_override("font_disabled_color", COLOR_HUD_MUTED)
	popup.add_theme_color_override("font_separator_color", COLOR_HUD_BORDER)
	popup.add_theme_font_size_override("font_size", 16)
	popup.add_theme_constant_override("v_separation", 8)
	popup.add_theme_constant_override("item_start_padding", 18)
	popup.add_theme_constant_override("item_end_padding", 22)


func _make_premium_stylebox(color: Color, radius: int, border_color: Color, border_width: int) -> StyleBoxFlat:
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
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style
