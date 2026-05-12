extends CanvasLayer

signal add_npc_requested
signal remove_npc_requested(npc_id: String)
signal respawn_npcs_requested
signal npc_movement_toggled(enabled: bool)
signal npc_chat_toggled(enabled: bool)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

var current_npcs: Array = []
var can_manage := true

@onready var panel: PanelContainer = $Root/Panel
@onready var npc_list_container: VBoxContainer = $Root/Panel/Margin/VBox/Scroll/NpcList
@onready var movement_toggle: CheckBox = $Root/Panel/Margin/VBox/Toggles/MovementToggle
@onready var chat_toggle: CheckBox = $Root/Panel/Margin/VBox/Toggles/ChatToggle
@onready var add_button: Button = $Root/Panel/Margin/VBox/Actions/AddButton
@onready var respawn_button: Button = $Root/Panel/Margin/VBox/Actions/RespawnButton
@onready var close_button: Button = $Root/Panel/Margin/VBox/Header/CloseButton
@onready var title_label: Label = $Root/Panel/Margin/VBox/Header/Title


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	UIThemeScript.apply_label(title_label)
	UIThemeScript.apply_primary_button(add_button)
	UIThemeScript.apply_secondary_button(respawn_button)
	UIThemeScript.apply_secondary_button(close_button)
	hide_panel()


func show_with_npcs(npcs: Array, movement_enabled: bool, chat_enabled: bool, next_can_manage: bool = true) -> void:
	visible = true
	can_manage = next_can_manage
	update_npcs(npcs, movement_enabled, chat_enabled)


func update_npcs(npcs: Array, movement_enabled: bool, chat_enabled: bool) -> void:
	current_npcs = npcs.duplicate(true)
	movement_toggle.set_pressed_no_signal(movement_enabled)
	chat_toggle.set_pressed_no_signal(chat_enabled)
	movement_toggle.disabled = not can_manage
	chat_toggle.disabled = not can_manage
	add_button.disabled = not can_manage
	respawn_button.disabled = not can_manage
	_render_npc_rows()


func hide_panel() -> void:
	visible = false


func _render_npc_rows() -> void:
	for child in npc_list_container.get_children():
		child.queue_free()

	if current_npcs.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No hay NPCs locales."
		UIThemeScript.apply_label(empty_label)
		npc_list_container.add_child(empty_label)
		return

	for data in current_npcs:
		if typeof(data) != TYPE_DICTIONARY:
			continue
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 34)
		var name_label := Label.new()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.text = "%s  (%s)" % [
			String(data.get("name", "NPC")),
			String(data.get("id", "npc")),
		]
		UIThemeScript.apply_label(name_label)

		var remove_button := Button.new()
		remove_button.text = "Quitar"
		remove_button.disabled = not can_manage
		UIThemeScript.apply_secondary_button(remove_button)
		var npc_id := String(data.get("id", ""))
		remove_button.pressed.connect(func() -> void:
			remove_npc_requested.emit(npc_id)
		)

		row.add_child(name_label)
		row.add_child(remove_button)
		npc_list_container.add_child(row)


func _on_add_button_pressed() -> void:
	if not can_manage:
		return
	add_npc_requested.emit()


func _on_respawn_button_pressed() -> void:
	if not can_manage:
		return
	respawn_npcs_requested.emit()


func _on_movement_toggle_toggled(button_pressed: bool) -> void:
	if not can_manage:
		return
	npc_movement_toggled.emit(button_pressed)


func _on_chat_toggle_toggled(button_pressed: bool) -> void:
	if not can_manage:
		return
	npc_chat_toggled.emit(button_pressed)


func _on_close_button_pressed() -> void:
	hide_panel()
	close_requested.emit()
