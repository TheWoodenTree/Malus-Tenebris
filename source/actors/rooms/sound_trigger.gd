@tool
extends Area3D

var sound_played: bool = false

@onready var collision_shape = $collision_shape
@onready var sound_player_3d = $sound_player_3d
@onready var sound_player = $sound_player

@export var size: Vector3 = Vector3.ONE : set = _set_size
@export var sound: AudioStream : set = _set_sound
@export var use_3d: bool = false
@export var amplify: float = 0.0


func _ready():
	collision_shape.shape.size = size
	sound_player.stream = sound
	sound_player.volume_db += amplify


func _on_body_entered(body):
	if body == Global.player and not sound_played:
		sound_player.play()
		sound_played = true


func _set_size(new_size):
	size = new_size
	if collision_shape:
		collision_shape.shape.size = new_size


func _set_sound(new_sound):
	sound = new_sound
	if sound_player:
		sound_player.stream = new_sound

