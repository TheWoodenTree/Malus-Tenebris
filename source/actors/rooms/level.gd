extends Node3D


func _on_Area_body_entered(body: Node) -> void:
	if body == Global.player:
		$sound_player.play()
