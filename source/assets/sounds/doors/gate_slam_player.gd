extends AudioStreamPlayer3D

func _process(_delta: float) -> void:
	if not playing:
		queue_free()
