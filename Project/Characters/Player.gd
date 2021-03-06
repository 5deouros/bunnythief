extends KinematicBody2D

# Walking variables:
var speed # Speed of player's movement
export var start_speed = float()
var target_pos =  Vector2() # Current target of where is playing moving to
var walk_target_array # Array of all positions of player's movement path
var move_enabled = false # Bool to check if player is allowed to move

# Animation variables:
export var female = bool() # Bool to check player's gender
var movement_axis = Vector2(0, 0) # Axis of direction in which player is moving
var animation_step # Number of animation action to be played

# Flower map variables
var flowers_map # TileMap with flower cells
export var offset = int() # Offset of moving TileMap
var flower_idx # index of the flower tile player is moving to

func _ready():
	speed = start_speed
	flowers_map = get_tree().get_nodes_in_group('flowers')[0]
	#manage_animation() # First calls management of animation to be sure that player's animation will start with the correct gender sprite
	pass

func _physics_process(delta):
	walk() # Method that moves player
	pass

func walk():
	# Checks if there is a path to be followed
	if walk_target_array != null && walk_target_array.size() != 0:
		# Checks if player's position is not the first point of the Array with the path to be followed
		if position != walk_target_array.front():
			var target_pos = walk_target_array.front() # Makes first point of movement path Array be target of walking direction
			
			# Here, will be checked if player is moving towards a planted tile
			if flowers_map.plants_grid.has(String(Vector3(target_pos.x - offset, target_pos.y - offset, 0))):
				# Checks if current flower tile's index isn't already the flower's index to avoid updating variable's value more than once
				if flower_idx != flowers_map.plants_grid[String(Vector3(target_pos.x - offset, target_pos.y - offset, 0))]:
					flower_idx = flowers_map.plants_grid[String(Vector3(target_pos.x - offset, target_pos.y - offset, 0))] # Updates flower index value
					
					# Here will be identified the kind of flower player is moving towards, according to flowers' TileSet order
					if flower_idx == 0:
						print("going to a pink square")
					elif flower_idx == 1:
						print("going to a yellow square")
					elif flower_idx == 2:
						print("going to a blue square")
			else: # If player's not moving to a recignized flower, it means this part of flowers' grid is empty, so tile index is -1
				if flower_idx != -1: # To avoid updating same value more than once
					flower_idx = -1
			if position == target_pos: # Checks if target position isn't already reached
				move_enabled = false # Disables movement
				movement_axis = Vector2(0, 0) # Updates movement axis to zero as player is not allowed to move
				#manage_animation() # Manages animation to switch to Idle
			if move_enabled: # If movement is still enabled (checks if player hasn't reached target yet)
				if target_pos != null: # Checks if target position is a valid position
					
					if !flowers_map.is_flower(position, offset) || !flowers_map.is_flower(target_pos, offset):
						# Here, is checked on which direction target position is relative to player's position and its values are updated to movement axis
						# An animation management is called after each update of axis position
						
						# To check direction relative to X axis
						if position.x < target_pos.x:
							position.x += speed
							movement_axis.x = 1
							#manage_animation()
						elif position.x > target_pos.x:
							position.x -= speed
							movement_axis.x = -1
							#manage_animation()
						else: movement_axis.x = 0; #manage_animation()
						
						# To check direction relative to Y axis
						if position.y < target_pos.y:
							position.y += speed
							movement_axis.y = 1
							#manage_animation()
						elif position.y > target_pos.y:
							position.y -= speed
							movement_axis.y = -1
							#manage_animation()
						else: movement_axis.y = 0; #manage_animation()
						
					elif flowers_map.is_flower(position, offset) && flowers_map.is_flower(target_pos, offset):
						pass
		else: # Removes first point from path points' Array to allow moving to the next point
			walk_target_array.remove(0)
			
			#manage_animation() # Calls an animation management to change to next moving point's direction
			move_enabled = true # Re-enables movement
			
		
	elif walk_target_array != null && walk_target_array.size() == 0: # If there is no path to be followed
		movement_axis = Vector2(0, 0) # Sets movement axis to 0 as player is not moving
		#manage_animation() # Calls an animation management to go back to Idle
	

func manage_animation(): # Method to check what animation should be played
	pass

