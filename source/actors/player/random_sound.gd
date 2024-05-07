extends Node3D

@export var max_sound_distance: float = 15.0
@export var min_sound_distance: float = 7.5
@export var max_sound_y_distance: float = 4.0
@export var mean_sound_interval: float = 20.0
@export var sound_interval_variance: float = 5.0
@export var stream: AudioStream

@onready var sound_player = $sound_player
@onready var sound_timer = $sound_timer


func _ready():
	sound_timer.wait_time = mean_sound_interval + randf_range(-sound_interval_variance, sound_interval_variance)
	sound_timer.start()


func _randomize_sound_position():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(min_sound_distance, max_sound_distance) * -1.0 if randi_range(0, 1) == 0 else 1.0
	random_position.y = randf_range(0.0, max_sound_y_distance) * -1.0 if randi_range(0, 1) == 0 else 1.0
	random_position.z = randf_range(min_sound_distance, max_sound_distance) * -1.0 if randi_range(0, 1) == 0 else 1.0
	sound_player.global_position = to_global(random_position)


func _on_sound_timer_timeout():
	_randomize_sound_position()
	sound_player.stream = stream
	sound_player.play()
	
	sound_timer.wait_time = mean_sound_interval + randf_range(-sound_interval_variance, sound_interval_variance)
	sound_timer.start()
