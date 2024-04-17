@tool
extends Area3D

var sound_played: bool = false

@onready var collision_shape = $collision_shape
@onready var sound_player_3d = $sound_player_3d
@onready var sound_player = $sound_player

@export var size: Vector3 = Vector3.ONE : set = _set_size
@export var sound: AudioStream : set = _set_sound
@export var use_3d: bool = false
@export var sound_player_3d_position: Vector3 = Vector3.ZERO : set = _set_sound_player_3d_position
@export var amplify: float = 0.0
@export_enum("Player", "Monster") var triggered_by: String = "Player"
@export var player_flag_name: String = ""
@export var trigger_fear: bool = false
@export var fear_duration: float = 5.0

signal triggered


func _ready():
	collision_shape.shape.size = size
	if use_3d:
		sound_player_3d.position = sound_player_3d_position
		sound_player_3d.stream = sound
		sound_player_3d.volume_db += amplify
	else:
		sound_player.stream = sound
		sound_player.volume_db += amplify


func _on_body_entered(body):
	# Optional flag in player script will be checked if player_flag_name is not blank
	var player_flag_true: bool = Global.player.get(player_flag_name) if player_flag_name else true
	var required_body: CharacterBody3D = Global.player if triggered_by == "Player" else Global.monster
	if body == required_body and not sound_played and player_flag_true:
		if use_3d:
			sound_player_3d.play()
		else:
			sound_player.play()
			
		if trigger_fear:
			#Global.main.fear_effect_timed(fear_duration)
			#Sound.enable_tension(3.0)
			pass
			
		sound_played = true
		emit_signal("triggered")


func _set_size(new_size):
	size = new_size
	if collision_shape:
		collision_shape.shape.size = new_size


func _set_sound(new_sound):
	sound = new_sound
	if sound_player:
		sound_player.stream = new_sound


func _set_sound_player_3d_position(position_: Vector3):
	sound_player_3d_position = position_
	if sound_player_3d:
		sound_player_3d.position = position_
