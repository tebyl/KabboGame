extends CanvasLayer

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const PermissionManagerScript := preload("res://scripts/data/PermissionManager.gd")
const DebugConfigScript := preload("res://scripts/data/DebugConfig.gd")
const VERSION_PATH := "res://VERSION.txt"

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
	UIThemeScript.apply_popup_menu_style(popup)
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
	popup.add_item("Reiniciar tutorial", 11)
	popup.add_separator()
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
	UIThemeScript.apply_dark_panel_style(top_bar)
	for label in [room_name_label, role_label, coins_label, help_text, saved_label, message_label]:
		UIThemeScript.apply_label(label)
	for button in $Root/TopBar/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			UIThemeScript.apply_secondary_button(button)
	UIThemeScript.apply_primary_button(decorate_button)
