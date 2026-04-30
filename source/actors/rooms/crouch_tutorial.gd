extends Area3D

var player_entered_area: bool = false
var player_crouched: bool = false


func _on_body_entered(body):
	if body == Global.player:
		if not player_entered_area:
			player_entered_area = true
			Global.player.state_machine.state_updated.connect(on_player_state_updated)
			Global.ui.hint_popup("Press and hold 'Left Control' to crouch", -1)
			if Global.player.current_state is PlayerCrouchWalkState:
				Global.player.state_machine.state_updated.disconnect(on_player_state_updated)
				await get_tree().create_timer(3.0, false).timeout
				player_crouched = true
				Global.ui.hint_remove()


func on_player_state_updated(state: State):
	if state is PlayerCrouchIdleState or state is PlayerCrouchWalkState:
		player_crouched = true
		Global.ui.hint_remove()
		Global.player.state_machine.state_updated.disconnect(on_player_state_updated)
