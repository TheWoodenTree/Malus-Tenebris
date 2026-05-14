class_name Menu
extends Control

@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export_enum("Remove", "Free") var close_action: String = "Remove"


# Overriden by child if action needs to be taken on open
func on_open():
	pass


# Overriden by child if action needs to be taken on close
func on_close():
	pass
