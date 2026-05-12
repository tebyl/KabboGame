extends CanvasLayer

signal furniture_selected(furniture_type: String)
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")

var inventory := {}
var current_category := ""
var selected_furniture_type := ""

@onready var panel: PanelContainer = $Root/Panel
@onready var category_list: VBoxContainer = $Root/Panel/Margin/VBox/Categories
@onready var item_list: VBoxContainer = $Root/Panel/Margin/VBox/Items


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	hide_inventory()
	_build_categories()


func setup_inventory(initial_inventory: Dictionary) -> void:
	inventory = initial_inventory.duplicate(true)
	var categories := FurnitureCatalogScript.get_categories()
	if current_category.is_empty() and not categories.is_empty():
		current_category = String(categories[0])
	populate_category(current_category)


func update_inventory(next_inventory: Dictionary) -> void:
	inventory = next_inventory.duplicate(true)
	if not current_category.is_empty():
		populate_category(current_category)


func show_inventory() -> void:
	panel.visible = true
	if item_list.get_child_count() == 0:
		var categories := FurnitureCatalogScript.get_categories()
		if not categories.is_empty():
			populate_category(String(categories[0]))


func hide_inventory() -> void:
	panel.visible = false


func populate_category(category: String) -> void:
	current_category = category
	for child in item_list.get_children():
		child.queue_free()

	for item in FurnitureCatalogScript.get_items_by_category(category):
		var furniture_type := String(item.get("type", ""))
		var count := int(inventory.get(furniture_type, 0))
		var size: Vector2i = FurnitureCatalogScript.get_size(furniture_type)
		var button := Button.new()
		button.text = "%s\n%sx%s  Cantidad: %s" % [
			String(item.get("name", furniture_type)),
			size.x,
			size.y,
			count,
		]
		button.disabled = count <= 0
		button.toggle_mode = true
		button.button_pressed = furniture_type == selected_furniture_type
		button.custom_minimum_size = Vector2(210, 48)
		UIThemeScript.apply_primary_button(button)
		if button.button_pressed:
			button.modulate = Color(1.0, 1.0, 0.82, 1.0)
		if count > 0:
			button.pressed.connect(_on_item_pressed.bind(furniture_type))
		item_list.add_child(button)

	var has_items := item_list.get_child_count() > 0
	if not has_items:
		var empty := Label.new()
		empty.text = "No hay muebles en esta categoria."
		UIThemeScript.apply_label(empty, true)
		item_list.add_child(empty)


func _build_categories() -> void:
	for child in category_list.get_children():
		child.queue_free()

	for category in FurnitureCatalogScript.get_categories():
		var button := Button.new()
		button.text = String(category)
		button.custom_minimum_size = Vector2(120, 30)
		UIThemeScript.apply_secondary_button(button)
		button.pressed.connect(populate_category.bind(String(category)))
		category_list.add_child(button)


func _on_item_pressed(furniture_type: String) -> void:
	selected_furniture_type = furniture_type
	populate_category(current_category)
	furniture_selected.emit(furniture_type)


func _on_close_pressed() -> void:
	hide_inventory()
	close_requested.emit()
