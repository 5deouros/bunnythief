extends TileMap

var grid = {} # To be tile world locations
var curtgt = Vector2() # Cursor pick
var curpos = Vector2() # Current position of player on grid
var astar = AStar.new() # AStar algorithm to 

var offset = 128 # Half the size of TileMap cells' size

var id_points_array = [] # ID (on Astar) of all tiles in order of the path found from current place to clicked place

var player # Moving body
var flowers # Flowers' TileMap that will superimpose walkable TileMap

var flowers_added = false # Variable to check if flowers' available tiles have already increased corresponding AStar algorithm cost

func _ready():
	# Array with used cells in tilemap on grid coordinate positions
	var tiles = get_used_cells()
	
	var idx = 0 # Index of each cell to be added to grid data's dictionary and to nodes on AStar graph
	# Deals with each of the cells in used cells' Array
	for pos in tiles:
		
		var tgt = map_to_world(pos,false) # Gets world position of each tilemap coordinate
		
		astar.add_point(idx, Vector3(tgt.x, tgt.y, 0), 1) # Adds position as node of AStar graph, with index in order starting from 0
		grid[String(Vector3(tgt.x, tgt.y, 0))] = idx # Adds AStar graph data to a dictionary with global position as key and index as value
		connect_nodes(pos, idx) # Creates connection on AStar graph with all found neighbour cells
		idx += 1 # Raises idx value to be added to next tile
		
	player = get_tree().get_nodes_in_group('player')[0] # Finds player instance by detecting nodes marked on group 'player'
	flowers = get_tree().get_nodes_in_group('flowers')[0] # Finds flowers'map instance by detecting nodes marked on group 'flowers'
	player.position = map_to_world(world_to_map(player.position)) # Aligns player's position to grid by getting his global position's equivalent grid position
	player.position = Vector2(player.position.x + offset, player.position.y + offset) # Brings player to a centralized grid position with cells' offset
	
	set_process(true) # Allows process to run


func _process(delta):
	update_from_to()
	update_grid()
	if Input.is_action_just_released("Click"): # When user clicks
		find_walking_path()

func connect_nodes(pos, point): # Method that finds a tile's neighbours on TileSet
	var tile_size = 256 # Size of tiles on TileMap
	var neighbours = {1: null, 2: null, 3: null, 4: null} # Dictionary to catch all 4 direction neighbours of current Tile
	
	var tgt = map_to_world(pos,false) # Gets current tile's world position
	
	# Here, all 8 neighbour possible positions are checked by looking if their position is a valid key on grid's dictionary
	
	if grid.has(String(Vector3(tgt.x, tgt.y - tile_size, 0))): # Checks if tile has a northern neighbour
		neighbours[1] = grid[String(Vector3(tgt.x, tgt.y - tile_size, 0))] 
	if grid.has(String(Vector3(tgt.x + tile_size, tgt.y, 0))): # Checks if tile has an eastern neighbour
		neighbours[2] = grid[String(Vector3(tgt.x + tile_size, tgt.y, 0))]
	if grid.has(String(Vector3(tgt.x, tgt.y + tile_size, 0))): # Checks if tile has a southern neighbour
		neighbours[3] = grid[String(Vector3(tgt.x, tgt.y + tile_size, 0))]
	if grid.has(String(Vector3(tgt.x - tile_size, tgt.y, 0))): # Checks if tile has a western neighbour
		neighbours[4] = grid[String(Vector3(tgt.x - tile_size, tgt.y, 0))]
	
	var neighbour_values = neighbours.values() # Adds all values of neighbours' dictionary into an Array
	
	# Deals with each value of found neighbours
	for value in neighbour_values:
		if value != null: # Checks if value isn't an empty neighbour
			astar.connect_points(point, value, true) # Connects AStar node to neighbour node

func find_walking_path():
	var from = Vector3(curpos.x, curpos.y, 0) # Sets player position to where AStar algorithm will start finding a path
	var to = Vector3(curtgt.x, curtgt.y, 0) # Sets mouse position to where AStar algorithm will find a path to
	
	if flowers.plants_grid.has(String(from)) && flowers.plants_grid.has(String(to)): # Checks if player is trying to move from a tile with flowers to another tile with flowers
		var path = [] # The idx Array that will be returned if a possible path is found
		var neighbours = astar.get_point_connections(grid[String(from)]) # idx Array of neighbours of current player position's corresponding cell
		var walkable_array = [] # The idx Array that will contain walkable neighbours of current player position's corresponding cell
		for neighbour in neighbours: # Deals with each neighbour found
			var pos = astar.get_point_position(neighbour) # Gets global position of given AStar index
			if !flowers.plants_grid.has(String(pos)): # Checks if there is no flower tile on neighbour's position
				walkable_array.append(neighbour) # Adds neighbour without flower on walkable Array
		while walkable_array != []:
			for walkable_cell in walkable_array:
				var possible_path = astar.get_id_path(walkable_cell, int(grid[String(to)]))
				if possible_path != null:
					path = possible_path
					walkable_array.clear()
				else:
					walkable_array.erase(walkable_cell)
		var new_array = []
		for id_point in path:
			if !new_array.has(Vector2(astar.get_point_position(id_point).x + offset, astar.get_point_position(id_point).y + offset)):
				new_array.append(Vector2(astar.get_point_position(id_point).x + offset, astar.get_point_position(id_point).y + offset))
		if player.walk_target_array != new_array:
			player.walk_target_array = new_array
		
	elif grid.has(String(from)) && grid.has(String(to)): # Checks if from and to are valid positions of AStar nodes by finding their location on grid dictionary
		id_points_array = astar.get_id_path(int(grid[String(from)]), int(grid[String(to)])) # Finds path and returns it to path Array
		var new_array = [] # Creates an empty array to convert AStar graph nodes' ID to their corresponding tiles' global position
		# Deals with each of the nodes found on AStar path
		for id_point in id_points_array:
			# Checks if AStar node being analyzed's position isn't already on new Array to avoid adding multiple paths by clicking many times
			if !new_array.has(Vector2(astar.get_point_position(id_point).x + offset, astar.get_point_position(id_point).y + offset)):
				# Adds AStar node's global position to new array
				new_array.append(Vector2(astar.get_point_position(id_point).x + offset, astar.get_point_position(id_point).y + offset))
		if player.walk_target_array != new_array: # Checks if player movement points' Array isn't already the same as the found path
			player.walk_target_array = new_array # Updates player movement points' Array with an array of positions of all AStar nodes on found path

func update_from_to():
	# Updates with mouse position converted to correspondig cell position on TileMap coordinates
	var tgt_cell = world_to_map( get_global_mouse_position() )
	# If mouse focuses a valid cell on TileMap
	if get_cell(tgt_cell.x, tgt_cell.y) != -1:
		# Gets world position of focused cell and sets it to cursor pick
		curtgt =  map_to_world(tgt_cell)
	else:
		curtgt = Vector2() # Unables cursor pick value
	
	# Updates with player position converted to corresponding cell position on TileMap coordinates
	var tgt_pos = world_to_map(player.position)
	# If player is on a valid cell of TileMap
	if get_cell(tgt_pos.x, tgt_pos.y) != -1:
		# Gets world position of player and sets it to player's current position
		curpos = map_to_world(tgt_pos)

func update_grid():
	if !flowers_added: # Checks if flowers' available tiles have already increased corresponding AStar algorithm cost
		if flowers.built: # Checks if flowers' grid has already been built
			var moving_tiles = grid.keys() # Gets all positions ov moveable cells stored in grid Dictionary into an Array
			for moving_tile in moving_tiles: # Deals with the position of each moveable cell
				if flowers.plants_grid.has(moving_tile): # Checks if a moveable cell has a flower tile in it
					astar.set_point_weight_scale(grid[String(moving_tile)], 4) # Changes the AStar node's cost to 2 on each flowered cell
			flowers_added = true # Marks that flowers' available tiles have already increased corresponding AStar algorithm cost


















