class_name IconlessButton
extends Button


func _on_button_up():
	Global.ui.button_up_player.play()


func _on_button_down():
	Global.ui.button_down_player.play()


func _on_mouse_entered():
	if not disabled:
		Global.ui.button_hover_player.play()
