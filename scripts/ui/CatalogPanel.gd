extends CanvasLayer

signal furniture_selected(furniture_type: String)
signal close_requested

const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")

@onready var panel: PanelContainer = $Root/Panel
@onready var category_list: VBoxContainer = $Root/Panel/Margin/VBox/Categories
@onready var item_list: VBoxContainer = $Root/Panel/Margin/VBox/Items


func _ready() -> void:
	hide_catalog()
	_build_categories()


func show_catalog() -> void:
	panel.visible = true
	if item_list.get_child_count() == 0:
		var categories: Array = FurnitureCatalogScript.get_categories()
		if not categories.is_empty():
			populate_category(categories[0])


func hide_catalog() -> void:
	panel.visible = false


func populate_category(category: String) -> void:
	for child in item_list.get_children():
		child.queue_free()

	for item in FurnitureCatalogScript.get_items_by_category(category):
		var button := Button.new()
		button.text = String(item.get("name", item.get("type", "")))
		button.custom_minimum_size = Vector2(160, 32)
		button.pressed.connect(_on_item_pressed.bind(String(item.get("type", ""))))
		item_list.add_child(button)


func _build_categories() -> void:
	for child in category_list.get_children():
		child.queue_free()

	for category in FurnitureCatalogScript.get_categories():
		var button := Button.new()
		button.text = category
		button.custom_minimum_size = Vector2(120, 30)
		button.pressed.connect(populate_category.bind(category))
		category_list.add_child(button)


func _on_item_pressed(furniture_type: String) -> void:
	furniture_selected.emit(furniture_type)


func _on_close_pressed() -> void:
	hide_catalog()
	close_requested.emit()
