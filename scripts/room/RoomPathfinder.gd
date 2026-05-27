class_name RoomPathfinder
extends RefCounted

const ORTHOGONAL_DIRECTIONS := [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

const DIAGONAL_DIRECTIONS := [
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]


static func find_path(
	start: Vector2i,
	goal: Vector2i,
	room_size: Vector2i,
	blocked_cells: Dictionary
) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if start == goal:
		return path
	if not is_inside(start, room_size) or not is_inside(goal, room_size):
		return path
	if is_blocked(goal, blocked_cells):
		return path

	var frontier: Array[Vector2i] = [start]
	var came_from := { start: start }

	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == goal:
			break

		for next in get_neighbors(current, room_size, blocked_cells):
			if came_from.has(next):
				continue
			frontier.append(next)
			came_from[next] = current

	if not came_from.has(goal):
		return path

	var current := goal
	while current != start:
		path.push_front(current)
		current = came_from[current]
	return path


static func get_neighbors(cell: Vector2i, room_size: Vector2i, blocked_cells: Dictionary) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for direction in ORTHOGONAL_DIRECTIONS:
		var next: Vector2i = cell + direction
		if is_inside(next, room_size) and not is_blocked(next, blocked_cells):
			neighbors.append(next)
	for direction in DIAGONAL_DIRECTIONS:
		var next: Vector2i = cell + direction
		if not is_inside(next, room_size) or is_blocked(next, blocked_cells):
			continue
		# Prevent corner cutting when adjacent orthogonal cells are blocked.
		var step_x := cell + Vector2i(direction.x, 0)
		var step_y := cell + Vector2i(0, direction.y)
		if is_blocked(step_x, blocked_cells) or is_blocked(step_y, blocked_cells):
			continue
		neighbors.append(next)
	return neighbors


static func is_inside(cell: Vector2i, room_size: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < room_size.x and cell.y < room_size.y


static func is_blocked(cell: Vector2i, blocked_cells: Dictionary) -> bool:
	return blocked_cells.has(cell)
