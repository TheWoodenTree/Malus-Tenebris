@abstract
class_name Event
extends Resource

@export var delay: float = 0.0
@export var trigger_once: bool = true

@export_storage var triggered: bool = false


func execute() -> void:
	if trigger_once and triggered:
		return
	
	if not is_zero_approx(delay):
		await Global.get_tree().create_timer(delay, false).timeout
	
	_execute()
	
	triggered = true


@abstract func _execute() -> void
