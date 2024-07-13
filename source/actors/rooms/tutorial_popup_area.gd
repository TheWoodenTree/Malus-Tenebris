extends Area3D

@export var message: String = ""
@export var duration: float = 3.0

var triggered: bool = false

func _on_body_entered(body):
	if body == Global.player and not triggered and not Global.player.debug_no_tutorials:
		Global.ui.hint_popup(message, duration)
		triggered = true
