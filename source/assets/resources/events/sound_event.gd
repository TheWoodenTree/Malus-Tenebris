class_name SoundEvent
extends Event

@export var audio_stream: AudioStream
@export var is_spatial: bool = false
@export var position: Vector3


func _execute() -> void:
	if is_spatial:
		SoundManager.play_3d(audio_stream, position)
	else:
		SoundManager.play(audio_stream)
