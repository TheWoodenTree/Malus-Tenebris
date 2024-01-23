extends Node3D

var can_trigger = true

@onready var sound_player = $sound_player


func _on_trigger_area_body_entered(_body):
#	if body == Global.player and can_trigger and Global.player.inventory.has("Lower Prison"):
#		#sound_player.play()
#		#await sound_player.finished
#		Sound.enable_tension(10.0)
#		can_trigger = false
	pass
