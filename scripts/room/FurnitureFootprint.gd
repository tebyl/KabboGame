class_name FurnitureFootprint
extends RefCounted


static func get_rotated_size(size: Vector2i, furniture_rotation: int) -> Vector2i:
	if posmod(furniture_rotation, 2) == 1:
		return Vector2i(size.y, size.x)
	return size


static func get_occupied_cells(cell: Vector2i, size: Vector2i, furniture_rotation: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var occupied_size := get_rotated_size(size, furniture_rotation)
	for x in range(occupied_size.x):
		for y in range(occupied_size.y):
			cells.append(cell + Vector2i(x, y))
	return cells


static func get_footprint_polygon(size: Vector2i, furniture_rotation: int, tile_width: int = 64, tile_height: int = 32) -> PackedVector2Array:
	var occupied_size := get_rotated_size(size, furniture_rotation)
	var max_cell := Vector2i(occupied_size.x - 1, occupied_size.y - 1)
	return PackedVector2Array([
		_grid_to_world(Vector2i(0, 0), tile_width, tile_height) + Vector2(0, -tile_height / 2.0),
		_grid_to_world(Vector2i(max_cell.x, 0), tile_width, tile_height) + Vector2(tile_width / 2.0, 0),
		_grid_to_world(max_cell, tile_width, tile_height) + Vector2(0, tile_height / 2.0),
		_grid_to_world(Vector2i(0, max_cell.y), tile_width, tile_height) + Vector2(-tile_width / 2.0, 0),
	])


static func get_visual_anchor_offset(size: Vector2i, furniture_rotation: int, tile_width: int = 64, tile_height: int = 32) -> Vector2:
	var occupied_size := get_rotated_size(size, furniture_rotation)
	var max_cell := Vector2i(occupied_size.x - 1, occupied_size.y - 1)
	return _grid_to_world(max_cell, tile_width, tile_height) + Vector2(0, tile_height / 2.0)


static func get_sprite_offset(
	size: Vector2i,
	furniture_rotation: int,
	texture_size: Vector2,
	catalog_sprite_offset: Vector2 = Vector2.ZERO,
	tile_width: int = 64,
	tile_height: int = 32
) -> Vector2:
	var visual_anchor := get_visual_anchor_offset(size, furniture_rotation, tile_width, tile_height)
	return visual_anchor - Vector2(0, texture_size.y / 2.0) + catalog_sprite_offset


static func cells_to_dict(cells: Array[Vector2i]) -> Dictionary:
	var result := {}
	for c in cells:
		result[c] = true
	return result


static func overlaps_any(cells: Array[Vector2i], blocked_cells: Dictionary) -> bool:
	for c in cells:
		if blocked_cells.has(c):
			return true
	return false


static func is_inside_room(cells: Array[Vector2i], room_size: Vector2i) -> bool:
	for c in cells:
		if c.x < 0 or c.y < 0 or c.x >= room_size.x or c.y >= room_size.y:
			return false
	return true


static func _grid_to_world(cell: Vector2i, tile_width: int, tile_height: int) -> Vector2:
	var world_x := float(cell.x - cell.y) * float(tile_width) / 2.0
	var world_y := float(cell.x + cell.y) * float(tile_height) / 2.0
	return Vector2(world_x, world_y)
