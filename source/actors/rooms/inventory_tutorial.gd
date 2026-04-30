extends Area3D

var player_entered_area: bool = false


func _on_body_entered(body):
	if body == Global.player and GameState.has_flag(GameState.Flag.PICKED_UP_CELL_HALL_KEY) and not player_entered_area:
		Global.ui.hint_popup("Open your inventory and pull out the key", 5.0)
		player_entered_area = true
