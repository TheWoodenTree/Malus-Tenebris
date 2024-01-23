extends Node3D

var door_closed = false


func _on_Area_body_entered(body: Node) -> void:
	if body == Global.player:
		var door_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		door_tween.tween_property(self, "rotation:y", 15.0 * PI / 180.0, 2)
		get_node("%door_open_player").play()


func _on_starting_door_close_area_body_entered(body: Node) -> void:
	if body == Global.player and not door_closed:
		var door_tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		door_tween.tween_property(self, "rotation:y", 90.0 * PI / 180.0, 1.46)
		get_node("%gate_slam_player").play()
		door_closed = true
