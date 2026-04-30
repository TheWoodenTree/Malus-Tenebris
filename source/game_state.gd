extends Node

enum Flag {
	PICKED_UP_CELL_HALL_KEY,
	HELD_CELL_HALL_KEY,
}

var flags: Dictionary[Flag, bool] = {}


func set_flag(flag: Flag):
	flags[flag] = true


func unset_flag(flag: Flag):
	flags[flag] = false


func has_flag(flag: Flag):
	return flags.has(flag)
