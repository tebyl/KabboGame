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
