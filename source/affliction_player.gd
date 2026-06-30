class_name DynamicAudioStreamPlayer
extends AudioStreamPlayer

@export_group("Affliction")
## Affliction timer time left threshold to play this audio. A value of -1 means this audio will
## play regardless of the affliction timer's value.
@export var min_volume_affliction_timer_threshold: float = -1.0
@export var max_volume_affliction_timer_threshold: float = -1.0


func _ready() -> void:
	volume_db = -80.0
	play()


func _process(_delta: float) -> void:
	var volume_strength: float = 1.0 - (AfflictionTimer.time_left - max_volume_affliction_timer_threshold) / (min_volume_affliction_timer_threshold - max_volume_affliction_timer_threshold)
	var clamped_volume_strenght: float = clamp(volume_strength, 0.0, 1.0)
	volume_db = clamp(linear_to_db(clamped_volume_strenght), -100.0, 0.0)
