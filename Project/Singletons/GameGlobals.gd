extends Node

# Variables used to create save file and store data
var save_data = {}
var slot = File.new()
var save_path = "user://save.dat"

# Variables to be saved
var level_number = int()

func load_game():
	slot.open(save_path, File.READ)
	var content = slot.get_var()
	slot.close()
	if content != null:
		print("there's something saved")
	pass

func save_game():
	slot.open(save_path, File.WRITE)
	slot.store_var(save_data)
	slot.close()
	pass

func get_scene_path():
	if level_number == 1:
		return ""
	pass