extends TileMap

var plants_grid = {} # Dictionary to store all plants' position data

func _ready():
	
	var ids = tile_set.get_tiles_ids() # Gets an Array with all IDs of the TileSet
	
	for id in ids: # Deals with each ID in IDs Array
		var plants = get_used_cells_by_id(id) # Finds the used cells on TileMap with each ID of the TileSet
		for plant in plants: # Deals with each tile instance of given ID
			var grid_pos = map_to_world(plant, false) # Converts grid position fo given tile into a world position
			plants_grid[String(Vector3(grid_pos.x, grid_pos.y, 0))] = id # Adds data to grid dictionary, with position as Key and TileSet ID as Value
	set_process(true) # Allows process to run

func delete_tile(tile_pos_v3): # Method to 'delete' a flower tile
	var pos = Vector2(tile_pos_v3.x, tile_pos_v3.y) # Converts given Vector3 into a Vector2
	set_cell(world_to_map(pos).x, world_to_map(pos).y, -1) # Sets obtained Vector2 into a grid position and setting its index on tilemap to -1 (empty)

func is_flower(pos_vec2, offset): # Method to check if given position has a valid flower tile
	if plants_grid.has(String(Vector3(pos_vec2.x - offset, pos_vec2.y - offset, 0))): return true # if given position is on grid, return true
	else: return false