extends Area3D

var player_entered_area: bool = false


func _on_body_entered(body):
	if body == Global.player and not player_entered_area:
		Global.ui.hint_popup("Press and hold 'Left Shift' to sprint", 5.0)
		player_entered_area = true
