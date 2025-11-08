class_name IconlessButton
extends Button

var is_mouse_inside := false


func _ready() -> void:
	button_up.connect(_on_button_up)
	button_down.connect(_on_button_down)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_button_up():
	if is_mouse_inside:
		Global.ui.button_up_player.play()


func _on_button_down():
	Global.ui.button_down_player.play()


func _on_mouse_entered():
	is_mouse_inside = true
	if not disabled:
		Global.ui.button_hover_player.play()


func _on_mouse_exited() -> void:
	is_mouse_inside = false
