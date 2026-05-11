extends CanvasLayer

signal rotate_requested
signal delete_requested
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")

@onready var panel: PanelContainer = $Root/Panel
@onready var info_label: Label = $Root/Panel/Margin/VBox/Info


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	hide_panel()


func show_with_furniture(data: Dictionary) -> void:
	visible = true
	update_furniture(data)


func hide_panel() -> void:
	visible = false


func update_furniture(data: Dictionary) -> void:
	var furniture_type := String(data.get("type", ""))
	var item := FurnitureCatalogScript.get_item(furniture_type)
	var display_name := String(item.get("name", furniture_type))
	var cell: Vector2i = data.get("cell", Vector2i.ZERO)
	var size: Vector2i = data.get("size", Vector2i.ONE)
	info_label.text = "%s\nTipo: %s\nTamano: %sx%s\nCelda: %s,%s\nRotacion: %s" % [
		display_name,
		furniture_type,
		size.x,
		size.y,
		cell.x,
		cell.y,
		int(data.get("rotation", 0)),
	]


func _on_rotate_pressed() -> void:
	rotate_requested.emit()


func _on_delete_pressed() -> void:
	delete_requested.emit()


func _on_close_pressed() -> void:
	close_requested.emit()
