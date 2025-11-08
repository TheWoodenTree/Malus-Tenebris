extends Node

signal save_started
signal saved
signal load_started
signal loaded

const SAVE_FILE = "user://savegame.bin"

var save_data: Dictionary[String, Dictionary]
var saver_loaders: Array[SaverLoader]

var is_saving := false
var is_loading := false


func save_game():
	save_started.emit()
	is_saving = true
	
	var new_save_data: Dictionary[String, Dictionary]
	
	for saver_loader: SaverLoader in saver_loaders:
		if is_instance_valid(saver_loader):
			new_save_data[saver_loader.unique_id] = saver_loader.save_data()
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_var(new_save_data, true)
	file.close()
	
	save_data = new_save_data
	
	is_saving = false
	saved.emit()


func load_game():
	load_started.emit()
	is_loading = true
	
	if not FileAccess.file_exists(SAVE_FILE):
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	save_data = file.get_var(true)
	file.close()
	
	for saver_loader: SaverLoader in saver_loaders:
		if not is_instance_valid(saver_loader):
			continue
		
		if not save_data.has(saver_loader.unique_id):
			saver_loader.parent.queue_free()
			continue
			
		var instance_save_data: Dictionary[String, Variant] = save_data[saver_loader.unique_id]
		saver_loader.load_data(instance_save_data)
	
	is_loading = false
	loaded.emit()


func register_saver_loader(saver_loader: SaverLoader):
	saver_loaders.append(saver_loader)
