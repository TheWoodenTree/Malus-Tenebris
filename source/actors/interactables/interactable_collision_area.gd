class_name InteractArea
extends Area3D

signal interact_ray_collided
signal interact_ray_stopped_colliding

signal allow_sheen_area_entered
signal allow_sheen_area_exited

signal fire_burning_sound_area_entered
signal fire_burning_sound_area_exited


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func on_interact_ray_collided():
	interact_ray_collided.emit()


func on_interact_ray_stopped_colliding():
	interact_ray_stopped_colliding.emit()


func _on_area_entered(area: Area3D):
	if area.get_collision_layer_value(12): # enable_sheen_area
		allow_sheen_area_entered.emit()
	elif area.get_collision_layer_value(15): # fire_area
		fire_burning_sound_area_entered.emit()


func _on_area_exited(area: Area3D):
	if area.get_collision_layer_value(12): # enable_sheen_area
		allow_sheen_area_exited.emit()
	elif area.get_collision_layer_value(15): # fire_area
		fire_burning_sound_area_exited.emit()
