class_name FurnitureRenderer
extends RefCounted

const FURNITURE_ITEM_SCENE := preload("res://scenes/room/FurnitureItem.tscn")

var layer: Node2D
var items_by_id := {}


func setup(target_layer: Node2D) -> void:
	layer = target_layer


func redraw(furniture_list: Array) -> void:
	clear()
	for data in furniture_list:
		add_furniture(data)


func add_furniture(data: Dictionary) -> Node:
	var item: Node = FURNITURE_ITEM_SCENE.instantiate()
	layer.add_child(item)
	item.setup(data)
	items_by_id[item.furniture_id] = item
	return item


func clear() -> void:
	items_by_id.clear()
	for child in layer.get_children():
		child.queue_free()


func select_furniture(furniture_id: String) -> void:
	clear_selection()
	var item: Node = items_by_id.get(furniture_id)
	if item:
		item.set_selected(true)


func clear_selection() -> void:
	for item in items_by_id.values():
		item.set_selected(false)


func get_furniture_at_cell(cell: Vector2i) -> Node:
	for item in items_by_id.values():
		if item.get_occupied_cells().has(cell):
			return item
	return null


func get_furniture_by_id(furniture_id: String) -> Node:
	return items_by_id.get(furniture_id)
