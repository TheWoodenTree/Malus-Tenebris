extends Area3D

var player_entered_area: bool = false
var player_crouched: bool = false


func _on_body_entered(body):
	if body == Global.player:
		if not player_entered_area:
			player_entered_area = true
			Global.player.crouched.connect(remove_tutorial)
			Global.ui.hint_popup("Press and hold 'Left Control' to crouch", -1)
			if Global.player.crouching:
				Global.player.crouched.disconnect(remove_tutorial)
				await get_tree().create_timer(3.0, false).timeout
				player_crouched = true
				Global.ui.hint_remove()


func remove_tutorial():
	player_crouched = true
	Global.ui.hint_remove()
	Global.player.crouched.disconnect(remove_tutorial)
