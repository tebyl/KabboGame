extends CanvasLayer

signal save_requested(profile_data: Dictionary)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

const ROOM_TYPES := [
	{ "value": "social", "label": "Social" },
	{ "value": "descanso", "label": "Descanso" },
	{ "value": "juegos", "label": "Juegos" },
	{ "value": "estudio", "label": "Estudio" },
	{ "value": "coleccion", "label": "Colección" },
	{ "value": "creativo", "label": "Creativo" },
	{ "value": "privado", "label": "Privado" },
]

const ROOM_MOODS := [
	{ "value": "relajada", "label": "Relajada" },
	{ "value": "fiesta", "label": "Fiesta" },
	{ "value": "conversacion", "label": "Conversación" },
	{ "value": "decoracion", "label": "Decoración" },
	{ "value": "privada", "label": "Privada" },
	{ "value": "exploracion", "label": "Exploracion" },
]

@onready var panel: PanelContainer = $Root/Panel
@onready var name_input: LineEdit = $Root/Panel/Margin/VBox/NameInput
@onready var description_input: TextEdit = $Root/Panel/Margin/VBox/DescriptionInput
@onready var type_select: OptionButton = $Root/Panel/Margin/VBox/TypeSelect
@onready var mood_select: OptionButton = $Root/Panel/Margin/VBox/MoodSelect
@onready var validation_label: Label = $Root/Panel/Margin/VBox/Validation


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	_populate_options(type_select, ROOM_TYPES)
	_populate_options(mood_select, ROOM_MOODS)
	hide_panel()


func show_with_room(room_data: Dictionary) -> void:
	visible = true
	name_input.text = String(room_data.get("name", "Sala"))
	description_input.text = String(room_data.get("description", ""))
	_select_option(type_select, ROOM_TYPES, String(room_data.get("room_type", "social")))
	_select_option(mood_select, ROOM_MOODS, String(room_data.get("mood", "relajada")))
	validation_label.visible = false


func hide_panel() -> void:
	visible = false


func _populate_options(option: OptionButton, values: Array) -> void:
	option.clear()
	for index in range(values.size()):
		var entry: Dictionary = values[index]
		option.add_item(String(entry.get("label", "")), index)


func _select_option(option: OptionButton, values: Array, target_value: String) -> void:
	for index in range(values.size()):
		var entry: Dictionary = values[index]
		if String(entry.get("value", "")) == target_value:
			option.select(index)
			return
	option.select(0)


func _get_selected_value(option: OptionButton, values: Array) -> String:
	var index := clampi(option.selected, 0, max(0, values.size() - 1))
	var entry: Dictionary = values[index]
	return String(entry.get("value", ""))


func _on_save_pressed() -> void:
	var safe_name := name_input.text.strip_edges()
	var safe_description := description_input.text.strip_edges()
	if safe_name.is_empty():
		_show_validation("El nombre no puede quedar vacío.")
		return
	if safe_description.length() > 120:
		_show_validation("La descripción admite hasta 120 caracteres.")
		return
	save_requested.emit({
		"name": safe_name,
		"description": safe_description,
		"room_type": _get_selected_value(type_select, ROOM_TYPES),
		"mood": _get_selected_value(mood_select, ROOM_MOODS),
	})


func _on_cancel_pressed() -> void:
	hide_panel()
	close_requested.emit()


func _show_validation(text: String) -> void:
	validation_label.text = text
	validation_label.visible = true
