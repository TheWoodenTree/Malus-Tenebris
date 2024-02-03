extends Area3D

var triggered: bool = false

@onready var door = %apothecary_doorway.door


func _on_body_entered(body):
	if not triggered and body == Global.player:
		door.open()
		triggered = true
