extends AudioStreamPlayer3D


# Delete player upon finishing playing sound
func _on_finished():
	queue_free()
