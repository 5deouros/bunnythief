extends TileMap

var plants_grid = {}

func _ready():
	
	var ids = tile_set.get_tiles_ids()
	
	for id in ids:
		var plants = get_used_cells_by_id(id)
		for plant in plants:
			var grid_pos = map_to_world(plant, false)
			plants_grid[String(Vector3(grid_pos.x, grid_pos.y, 0))] = id