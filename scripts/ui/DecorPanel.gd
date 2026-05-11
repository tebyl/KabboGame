extends CanvasLayer

signal floor_type_selected(floor_type: String)
signal wall_type_selected(wall_type: String)
signal rotate_preview_requested
signal cancel_preview_requested
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")

const FLOOR_TYPES := [
	"beige_basic", "beige_dark", "cream_basic", "brown_basic",
	"beige_border", "beige_diagonal", "beige_center", "beige_worn",
	"dark_tile", "blue_tile", "red_tile", "green_tile",
	"marble_tile", "wood_parquet", "checker_tile", "premium_gold_tile",
]

const WALL_TYPES := ["default", "trim", "dark", "pastel", "blue", "green", "red", "purple"]

var current_floor_type := "beige_basic"
var current_wall_type := "default"

@onready var panel: PanelContainer = $Root/Panel
@onready var floor_list: GridContainer = $Root/Panel/Margin/VBox/FloorList
@onready var wall_list: GridContainer = $Root/Panel/Margin/VBox/WallList


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	_build_buttons()
	hide_panel()


func show_panel(next_floor_type: String, next_wall_type: String) -> void:
	current_floor_type = next_floor_type
	current_wall_type = next_wall_type
	visible = true
	_refresh_button_states()


func hide_panel() -> void:
	visible = false


func set_current_floor_type(floor_type: String) -> void:
	current_floor_type = floor_type
	_refresh_button_states()


func set_current_wall_type(wall_type: String) -> void:
	current_wall_type = wall_type
	_refresh_button_states()


func _build_buttons() -> void:
	for floor_type in FLOOR_TYPES:
		var button := _make_button(floor_type)
		button.pressed.connect(_on_floor_pressed.bind(floor_type))
		floor_list.add_child(button)
	for wall_type in WALL_TYPES:
		var button := _make_button(wall_type)
		button.pressed.connect(_on_wall_pressed.bind(wall_type))
		wall_list.add_child(button)


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(116, 28)
	UIThemeScript.apply_secondary_button(button)
	return button


func _refresh_button_states() -> void:
	if not is_node_ready():
		return
	for button in floor_list.get_children():
		if button is Button:
			button.disabled = button.text == current_floor_type
	for button in wall_list.get_children():
		if button is Button:
			button.disabled = button.text == current_wall_type


func _on_floor_pressed(floor_type: String) -> void:
	current_floor_type = floor_type
	_refresh_button_states()
	floor_type_selected.emit(floor_type)


func _on_wall_pressed(wall_type: String) -> void:
	current_wall_type = wall_type
	_refresh_button_states()
	wall_type_selected.emit(wall_type)


func _on_rotate_preview_pressed() -> void:
	rotate_preview_requested.emit()


func _on_cancel_preview_pressed() -> void:
	cancel_preview_requested.emit()


func _on_close_pressed() -> void:
	hide_panel()
	close_requested.emit()
