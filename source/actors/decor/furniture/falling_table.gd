extends Node3D

const FALL_POSITION: Vector3 = Vector3(21.25, 1.21, 26.0)
const FALL_ROTATION: Vector3 = Vector3(0.0, 31.4, -87.9)
const CRATE_FALL_POSITION: Vector3 = Vector3(23.0, 1.0, 25.25)
const CRATE_FALL_ROTATION: Vector3 = Vector3(-90.0, -75.0, 0.0)

@onready var sound_trigger_area = %sound_trigger
@onready var falling_crate = %falling_crate


func _ready():
	sound_trigger_area.triggered.connect(fall_over)


func fall_over():
	Global.monster.global_position = get_parent().get_node("monster_start_point").global_position
	Global.monster.walk_in_servants_quarters_event(get_parent().get_node("monster_mid_point").global_position)
	position = FALL_POSITION
	rotation_degrees = FALL_ROTATION
	falling_crate.position = CRATE_FALL_POSITION
	falling_crate.rotation_degrees = CRATE_FALL_ROTATION
	Global.world.get_node("nav_region").bake_navigation_mesh()
