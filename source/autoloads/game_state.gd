extends Node

enum Flag {
	HELD_FIRST_ITEM,
	PICKED_UP_CELL_HALL_KEY,
	HELD_CELL_HALL_KEY,
}

var flags: Dictionary[Flag, bool] = {}

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String


func set_flag(flag: Flag):
	flags[flag] = true


func unset_flag(flag: Flag):
	flags[flag] = false


func has_flag(flag: Flag):
	return flags.has(flag)


func get_save_properties():
	return ["flags"] as Array[String]
