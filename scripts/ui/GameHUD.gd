extends CanvasLayer

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

signal decorate_toggled(enabled: bool)
signal rotate_selected_requested
signal delete_selected_requested
signal inventory_requested
signal save_requested
signal profile_requested
signal shop_requested
signal rooms_requested

@onready var room_name_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/RoomName
@onready var player_name_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/PlayerName
@onready var coins_label: Label = $Root/TopBar/MarginContainer/HBoxContainer/CoinsLabel
@onready var decorate_button: Button = $Root/TopBar/MarginContainer/HBoxContainer/DecorateButton
@onready var top_bar: PanelContainer = $Root/TopBar
@onready var help_text: Label = $Root/HelpText
@onready var saved_label: Label = $Root/SavedLabel
@onready var message_label: Label = $Root/MessageLabel


func _ready() -> void:
	_apply_styles()
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
	player_name_label.text = player_name


func set_coins(value: int) -> void:
	if not is_node_ready():
		await ready
	coins_label.text = "Monedas: %s" % value


func set_decorate_enabled(enabled: bool) -> void:
	decorate_button.set_pressed_no_signal(enabled)
	decorate_button.text = "Decora ON" if enabled else "Decora"
	help_text.text = "Selecciona o coloca muebles" if enabled else "Click para caminar"


func set_decoration_enabled(enabled: bool) -> void:
	set_decorate_enabled(enabled)


func _on_decorate_toggled(enabled: bool) -> void:
	set_decorate_enabled(enabled)
	decorate_toggled.emit(enabled)
	if enabled:
		inventory_requested.emit()


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
	for label in [room_name_label, player_name_label, coins_label, help_text, saved_label, message_label]:
		UIThemeScript.apply_label(label)
	for button in $Root/TopBar/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			UIThemeScript.apply_secondary_button(button)
	UIThemeScript.apply_primary_button(decorate_button)
