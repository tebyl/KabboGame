class_name FurnitureCatalog
extends RefCounted

const ITEMS := [
	{ "type": "chair", "name": "Silla", "size": Vector2i(1, 1), "sprite_offset": Vector2(0.5, 8), "category": "Asientos", "price": 25 },
	{ "type": "sofa", "name": "Sofá", "size": Vector2i(2, 1), "sprite_offset": Vector2(1, 0), "category": "Asientos", "price": 100 },
	{ "type": "lounge_chair", "name": "Sillón Lounge", "size": Vector2i(1, 1), "sprite_offset": Vector2(2.5, 8), "category": "Asientos", "price": 180 },
	{ "type": "table", "name": "Mesa", "size": Vector2i(2, 1), "sprite_offset": Vector2(1.5, 13), "category": "Mesas", "price": 50 },
	{ "type": "desk", "name": "Escritorio", "size": Vector2i(2, 1), "sprite_offset": Vector2(1, 11), "category": "Mesas", "price": 120 },
	{ "type": "bed", "name": "Cama", "size": Vector2i(2, 2), "sprite_offset": Vector2(-1, 11), "category": "Dormitorio", "price": 160 },
	{ "type": "plant", "name": "Planta", "size": Vector2i(1, 1), "sprite_offset": Vector2(-0.5, 10), "category": "Decoración", "price": 35 },
	{ "type": "big_plant", "name": "Planta grande", "size": Vector2i(1, 1), "sprite_offset": Vector2(0, 6), "category": "Decoración", "price": 90 },
	{ "type": "golden_plant", "name": "Planta dorada", "size": Vector2i(1, 1), "sprite_offset": Vector2(-0.5, 11), "category": "Decoración", "price": 300 },
	{ "type": "lamp", "name": "Lámpara", "size": Vector2i(1, 1), "sprite_offset": Vector2(1.5, 9), "category": "Decoración", "price": 45 },
	{ "type": "bookshelf", "name": "Estantería", "size": Vector2i(1, 2), "sprite_offset": Vector2(0.5, 9), "category": "Decoración", "price": 130 },
	{ "type": "poster", "name": "Póster", "size": Vector2i(1, 1), "sprite_offset": Vector2(0.5, 11), "category": "Decoración", "price": 30 },
	{ "type": "floor_tile", "name": "Baldosa", "size": Vector2i(1, 1), "sprite_offset": Vector2(0, 0), "category": "Decoración", "price": 30 },
	{ "type": "rug", "name": "Alfombra", "size": Vector2i(2, 2), "sprite_offset": Vector2(-0.5, 22), "category": "Alfombras", "price": 70 },
	{ "type": "red_rug", "name": "Alfombra roja", "size": Vector2i(2, 2), "sprite_offset": Vector2(0, 21), "category": "Alfombras", "price": 100 },
	{ "type": "blue_rug", "name": "Alfombra azul", "size": Vector2i(2, 2), "sprite_offset": Vector2(0.5, 21), "category": "Alfombras", "price": 120 },
]


static func get_items() -> Array:
	return ITEMS.duplicate(true)


static func get_item(type: String) -> Dictionary:
	for item in ITEMS:
		if item.get("type", "") == type:
			return item.duplicate(true)
	return {}


static func get_size(type: String) -> Vector2i:
	return get_item(type).get("size", Vector2i(1, 1))


static func get_sprite_offset(type: String) -> Vector2:
	return get_item(type).get("sprite_offset", Vector2.ZERO)


static func get_price(type: String) -> int:
	return max(0, int(get_item(type).get("price", 50)))


static func get_shop_items() -> Array:
	return get_items()


static func get_categories() -> Array:
	var categories := []
	for item in ITEMS:
		var category := String(item.get("category", ""))
		if not categories.has(category):
			categories.append(category)
	return categories


static func get_items_by_category(category: String) -> Array:
	var result := []
	for item in ITEMS:
		if item.get("category", "") == category:
			result.append(item.duplicate(true))
	return result
