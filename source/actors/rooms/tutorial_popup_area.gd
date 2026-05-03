extends Area3D

@export var message: String = ""
@export var duration: float = 3.0

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body == Global.player and not triggered and not Global.player.debug_no_tutorials:
		Global.ui.show_hint(message, duration)
		triggered = true
