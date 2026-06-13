class_name Menu
extends Control

@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export_enum("Remove", "Free") var close_action: String = "Remove"


func on_open():
	pass

func on_returned_to():
	pass

func on_close():
	pass
