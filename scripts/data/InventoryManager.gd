class_name InventoryManager
extends RefCounted

var items := {}


func setup(initial_items: Dictionary) -> void:
	items.clear()
	load_save_data(initial_items)


func get_items() -> Dictionary:
	return items.duplicate(true)


func get_count(furniture_type: String) -> int:
	return int(items.get(furniture_type, 0))


func has_item(furniture_type: String) -> bool:
	return get_count(furniture_type) > 0


func add_item(furniture_type: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	set_count(furniture_type, get_count(furniture_type) + amount)


func remove_item(furniture_type: String, amount: int = 1) -> bool:
	if amount <= 0:
		return true
	if get_count(furniture_type) < amount:
		return false
	set_count(furniture_type, get_count(furniture_type) - amount)
	return true


func set_count(furniture_type: String, amount: int) -> void:
	items[furniture_type] = max(0, amount)


func to_save_data() -> Dictionary:
	return get_items()


func load_save_data(data: Dictionary) -> void:
	for key in data.keys():
		set_count(String(key), int(data.get(key, 0)))
