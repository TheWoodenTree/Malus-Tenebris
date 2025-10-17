extends Node

const SAVE_FILE = "user://savegame.bin"

var save_data: Dictionary[StringName, Dictionary]
var saver_loaders: Array[SaverLoader]


func save_game():
	var new_save_data: Dictionary[StringName, Dictionary]
	
	for saver_loader: SaverLoader in saver_loaders:
		if is_instance_valid(saver_loader):
			new_save_data[saver_loader.unique_id] = saver_loader.save_data()
			print(InventoryManager.items)
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(new_save_data, true)
	file.close()
	
	save_data = new_save_data


func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	save_data = file.get_var(true)
	file.close()
	
	for saver_loader: SaverLoader in saver_loaders:
		if is_instance_valid(saver_loader):
			var instance_save_data: Dictionary[StringName, Variant] = save_data[saver_loader.unique_id]
			saver_loader.load_data(instance_save_data)


func register_saver_loader(saver_loader: SaverLoader):
	saver_loaders.append(saver_loader)
