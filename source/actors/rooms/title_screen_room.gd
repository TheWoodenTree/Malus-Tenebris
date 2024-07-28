extends Node3D

@onready var camera = $camera

signal camera_moved


func move_camera_forward():
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "position:x", 6.0, 3.0)
	tween.tween_callback(camera_moved.emit)
