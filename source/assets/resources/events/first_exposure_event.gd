class_name FirstExposureEvent
extends Event

const SWELL_3 = preload("uid://bux643ngk65sf")


func _execute() -> void:
	AfflictionEffectController.set_to_beyond_max_effect(3.0)
	SoundManager.play(SWELL_3)
	
	await Global.get_tree().create_timer(10.0, false).timeout
	AfflictionEffectController.set_to_max_effect(2.0)
