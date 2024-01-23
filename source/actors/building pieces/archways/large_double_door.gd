@tool
extends Node3D

@export var door1_angle: int = 0: set = _set_door1_angle
@export var door2_angle: int = 0: set = _set_door2_angle
@export var door1_to_angle: int = 0
@export var door2_to_angle: int = 0

@onready var door1_hinge: Marker3D = $door1_hinge
@onready var door2_hinge: Marker3D = $door2_hinge
@onready var door1_dust_particles: GPUParticles3D = $door1_hinge/dust_particles
@onready var door2_dust_particles: GPUParticles3D = $door2_hinge/dust_particles
@onready var door_budge_player: AudioStreamPlayer3D = $door_budge_player
@onready var door_open_player: AudioStreamPlayer3D = $door_open_player
@onready var door_closed_player: AudioStreamPlayer3D = $door_closed_player

signal finished


func _ready():
	door1_hinge.rotation.y = deg_to_rad(door1_angle)
	door2_hinge.rotation.y = -deg_to_rad(door2_angle)


func _process(_delta):
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("debug"):
			open()


func _set_door1_angle(rot):
	door1_angle = rot
	if door1_hinge:
		door1_hinge.rotation.y = deg_to_rad(rot)


func _set_door2_angle(rot):
	door2_angle = rot
	if door2_hinge:
		door2_hinge.rotation.y = -deg_to_rad(rot)


func interact():
	open()


func on_winch_turn(winch_ang_vel_x: float):
	var door1_finished: bool = false
	var door2_finished: bool = false
	if not door_open_player.playing and abs(winch_ang_vel_x) > 0.1:
		door_open_player.play()
		door1_dust_particles.emitting = true
		door2_dust_particles.emitting = true
		
	if door1_hinge.rotation_degrees.y > door1_to_angle:
		door1_hinge.rotation.y += winch_ang_vel_x * 0.0008
	else:
		door1_finished = true
		door1_hinge.rotation.y = deg_to_rad(door1_to_angle)
		
	if door2_hinge.rotation_degrees.y < -door2_to_angle:
		door2_hinge.rotation.y -= winch_ang_vel_x * 0.0008
	else:
		door2_finished = true
		door2_hinge.rotation.y = -deg_to_rad(door2_to_angle)
	
	if door1_finished and door2_finished:
		door_open_player.stop()
		door1_dust_particles.emitting = false
		door2_dust_particles.emitting = false
		emit_signal("finished")


func open():
	var door1_budge_angle: int = -1
	var door2_budge_angle: int = -1
	if door1_to_angle - door1_angle > 0:
		door1_budge_angle = 1
		door1_dust_particles.position.z = -0.5
	if door2_to_angle - door2_angle > 0:
		door2_budge_angle = 1
		door2_dust_particles.position.z = -0.5
	
	var door_budge_tween = get_tree().create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	if door1_angle != door1_to_angle:
		door_budge_tween.tween_property(door1_hinge, "rotation:y", deg_to_rad(door1_budge_angle), 0.35).from(deg_to_rad(door1_angle)).as_relative()
	if door2_angle != door2_to_angle:
		door_budge_tween.tween_property(door2_hinge, "rotation:y", -deg_to_rad(door2_budge_angle), 0.35).from(-deg_to_rad(door2_angle)).as_relative()
	door_budge_player.play()
	
	await door_budge_tween.finished
	await get_tree().create_timer(0.2).timeout
	
	var doors_open_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	if door1_angle != door1_to_angle:
		doors_open_tween.tween_property(door1_hinge, "rotation:y", deg_to_rad(door1_to_angle), 5.5)
		door1_dust_particles.emitting = true
	if door2_angle != door2_to_angle:
		door2_dust_particles.emitting = true
		doors_open_tween.tween_property(door2_hinge, "rotation:y", -deg_to_rad(door2_to_angle), 5.5)
	door_open_player.play()
	await doors_open_tween.finished
	#door_closed_player.play()
	door1_dust_particles.emitting = false
	door2_dust_particles.emitting = false
