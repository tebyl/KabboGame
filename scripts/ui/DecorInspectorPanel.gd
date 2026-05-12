extends CanvasLayer

signal rotate_requested
signal move_requested
signal delete_requested
signal close_requested

const UIThemeScript := preload("res://scripts/ui/UITheme.gd")
const FurnitureCatalogScript := preload("res://scripts/data/FurnitureCatalog.gd")

@onready var panel: PanelContainer = $Root/Panel
@onready var info_label: Label = $Root/Panel/Margin/VBox/Info
@onready var delete_button: Button = $Root/Panel/Margin/VBox/Buttons/Delete
@onready var delete_confirm_label: Label = $Root/Panel/Margin/VBox/DeleteConfirm

var delete_confirmation_pending := false


func _ready() -> void:
	UIThemeScript.apply_panel_style(panel)
	hide_panel()


func show_with_furniture(data: Dictionary) -> void:
	visible = true
	update_furniture(data)


func hide_panel() -> void:
	visible = false
	_reset_delete_confirmation()


func update_furniture(data: Dictionary) -> void:
	_reset_delete_confirmation()
	var furniture_type := String(data.get("type", ""))
	var item := FurnitureCatalogScript.get_item(furniture_type)
	var display_name := String(item.get("name", furniture_type))
	var cell: Vector2i = data.get("cell", Vector2i.ZERO)
	var size := FurnitureCatalogScript.get_size(furniture_type)
	info_label.text = "%s\nTipo: %s\nTamaño: %sx%s\nCelda: %s,%s\nRotación: %s" % [
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


func _on_move_pressed() -> void:
	_reset_delete_confirmation()
	move_requested.emit()


func _on_delete_pressed() -> void:
	if not delete_confirmation_pending:
		delete_confirmation_pending = true
		delete_button.text = "Confirmar"
		delete_confirm_label.visible = true
		return
	delete_requested.emit()
	_reset_delete_confirmation()


func _on_close_pressed() -> void:
	_reset_delete_confirmation()
	close_requested.emit()


func _reset_delete_confirmation() -> void:
	delete_confirmation_pending = false
	if is_node_ready():
		delete_button.text = "Eliminar"
		delete_confirm_label.visible = false
