extends RefCounted

static func grid_to_world(cell: Vector2i, tile_width: int = 64, tile_height: int = 32) -> Vector2:
	var world_x := float(cell.x - cell.y) * float(tile_width) / 2.0
	var world_y := float(cell.x + cell.y) * float(tile_height) / 2.0
	return Vector2(world_x, world_y)


static func world_to_grid(pos: Vector2, tile_width: int = 64, tile_height: int = 32) -> Vector2i:
	var half_width := float(tile_width) / 2.0
	var half_height := float(tile_height) / 2.0
	var grid_x := (pos.x / half_width + pos.y / half_height) / 2.0
	var grid_y := (pos.y / half_height - pos.x / half_width) / 2.0
	return Vector2i(roundi(grid_x), roundi(grid_y))
