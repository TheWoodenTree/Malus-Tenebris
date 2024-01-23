extends Node3D

@onready var shriek_player = $shriek_player
@onready var distant_crash_player = $distant_crash_player
@onready var lever = $lever
@onready var stone_door_wall = $stone_door_wall

func _ready() -> void:
	lever.connect("lever_pulled",Callable(self,"stone_door_progress"))


func stone_door_progress(index):
	var light
	if index == 0:
		play_crash_sound()
		light = stone_door_wall.get_node("lever_count_light/mesh").mesh
	
	var mat = light.surface_get_material(0)
	var color_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	color_tween.tween_property(mat, "albedo_color", Color.WHITE, 3.0)
	color_tween.tween_callback(Callable(mat, "set").bind("flags_unshaded", true))


func play_crash_sound():
	await get_tree().create_timer(5.0).timeout
	#var tween = get_tree().create_tween()
	#tween.tween_property(distant_crash_player, "position:z", -200.0, 10.0).as_relative()
	distant_crash_player.play()
	#await get_tree().create_timer(3.0).timeout
	#shriek_player.play()
	
