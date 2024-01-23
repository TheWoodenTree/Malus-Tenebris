extends Area3D

var player_entered_area: bool = false
var player_crouched: bool = false


func _ready():
	Global.player.crouched.connect(func(): player_crouched = true; Global.ui.hint_remove())


func _on_body_entered(body):
	if body == Global.player:
		if not player_entered_area:
			Global.ui.hint_popup("Press and hold 'Left Control' to crouch", -1)
		player_entered_area = true
