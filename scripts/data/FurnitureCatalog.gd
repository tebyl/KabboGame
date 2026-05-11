class_name FurnitureCatalog
extends RefCounted

const ITEMS := [
	{ "type": "chair", "name": "Silla", "size": Vector2i(1, 1), "category": "Asientos", "price": 25 },
	{ "type": "sofa", "name": "Sofa", "size": Vector2i(2, 1), "category": "Asientos", "price": 80 },
	{ "type": "lounge_chair", "name": "Sillon Lounge", "size": Vector2i(1, 1), "category": "Asientos", "price": 120 },
	{ "type": "table", "name": "Mesa", "size": Vector2i(2, 1), "category": "Mesas", "price": 50 },
	{ "type": "desk", "name": "Escritorio", "size": Vector2i(2, 1), "category": "Mesas", "price": 90 },
	{ "type": "bed", "name": "Cama", "size": Vector2i(2, 2), "category": "Dormitorio", "price": 140 },
	{ "type": "plant", "name": "Planta", "size": Vector2i(1, 1), "category": "Decoracion", "price": 30 },
	{ "type": "big_plant", "name": "Planta grande", "size": Vector2i(1, 1), "category": "Decoracion", "price": 65 },
	{ "type": "golden_plant", "name": "Planta dorada", "size": Vector2i(1, 1), "category": "Decoracion", "price": 250 },
	{ "type": "lamp", "name": "Lampara", "size": Vector2i(1, 1), "category": "Decoracion", "price": 40 },
	{ "type": "bookshelf", "name": "Estante", "size": Vector2i(1, 2), "category": "Decoracion", "price": 100 },
	{ "type": "poster", "name": "Poster", "size": Vector2i(1, 1), "category": "Decoracion", "price": 20 },
	{ "type": "rug", "name": "Alfombra", "size": Vector2i(2, 2), "category": "Alfombras", "price": 70 },
	{ "type": "red_rug", "name": "Alfombra roja", "size": Vector2i(2, 2), "category": "Alfombras", "price": 90 },
	{ "type": "blue_rug", "name": "Alfombra azul", "size": Vector2i(2, 2), "category": "Alfombras", "price": 110 },
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


static func get_price(type: String) -> int:
	return int(get_item(type).get("price", 0))


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
