class_name RandomSound
extends Node3D

@export var stream: AudioStream
@export var playing: bool = true : set = _set_playing

@export_group("Position")
@export var min_distance: float = 7.5
@export var max_distance: float = 15.0
@export var max_y_distance: float = 4.0
@export var only_play_behind: bool = false

@export_group("Frequency")
@export var mean_interval: float = 20.0
@export var interval_variance: float = 5.0

@export_group("Affliction")
## Affliction timer time left threshold to play this sound. A value of -1 means this sound will
## play regardless of the affliction timer's value.
@export var min_volume_affliction_timer_threshold: float = -1.0
@export var max_volume_affliction_timer_threshold: float = -1.0

@onready var sound_player = $SoundPlayer
@onready var sound_timer = $SoundTimer


func _ready():
	if playing:
		start_timer()


func start_timer():
	sound_timer.wait_time = mean_interval + randf_range(-interval_variance, interval_variance)
	sound_timer.start()


func _randomize_sound_position():
	var random_position := Vector3.ZERO
	random_position.x = randf_range(min_distance, max_distance) * -1.0 if randi_range(0, 1) == 0 else 1.0
	random_position.y = randf_range(0.0, max_y_distance) * -1.0 if randi_range(0, 1) == 0 else 1.0
	random_position.z = randf_range(min_distance, max_distance) * -1.0 if randi_range(0, 1) == 0 and not only_play_behind else 1.0
	sound_player.global_position = to_global(random_position)


func _on_sound_timer_timeout():
	_randomize_sound_position()
	sound_player.stream = stream
	
	var volume_strength: float = 1.0 - (AfflictionTimer.time_left - max_volume_affliction_timer_threshold) / (min_volume_affliction_timer_threshold - max_volume_affliction_timer_threshold)
	
	if is_equal_approx(-1.0, min_volume_affliction_timer_threshold) or \
			AfflictionTimer.time_left < min_volume_affliction_timer_threshold or \
			is_equal_approx(AfflictionTimer.time_left, min_volume_affliction_timer_threshold):
		
		if not is_equal_approx(min_volume_affliction_timer_threshold, max_volume_affliction_timer_threshold):
			sound_player.volume_db = linear_to_db(pow(volume_strength, 2.0))
		else:
			sound_player.volume_db = 0.0
		
		sound_player.play()
		
	start_timer()


func _set_playing(playing_: bool):
	playing = playing_
	if playing:
		start_timer()
	else:
		sound_timer.stop()
