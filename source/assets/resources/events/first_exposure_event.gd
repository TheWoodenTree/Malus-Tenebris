class_name FirstExposureEvent
extends Event

const SWELL_3 = preload("uid://bux643ngk65sf")
const BUILDUP_TIME = 3.0


func _execute() -> void:
	AfflictionEffectController.set_to_beyond_max_effect(BUILDUP_TIME)
	AfflictionTimer.set_time_secs(0.0, BUILDUP_TIME)
	AfflictionTimer.unpause()
	SoundManager.play(SWELL_3)
	
	await Global.get_tree().create_timer(BUILDUP_TIME + 0.1, false).timeout
	GameState.set_flag(GameState.Flag.FIRST_EXPOSURE_OCCURRED)
	
	await Global.get_tree().create_timer(7.0, false).timeout
	AfflictionEffectController.set_to_max_effect(2.0)
