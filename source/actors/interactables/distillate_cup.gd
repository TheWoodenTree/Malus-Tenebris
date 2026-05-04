extends Interactable

signal done_pouring

var num_doses: int = 0
var first_dose: bool = true

@onready var pour_player = $PourPlayer


func _on_target():
	if num_doses > 0:
		var doses_left_string: String = ("Contains %d " % num_doses) + ("dose" if num_doses == 1 else "doses")
		Global.ui.show_hint(doses_left_string, -1)


func _on_untarget():
	Global.ui.remove_hint()


func _on_interact() -> void:	
	if num_doses > 0:
		if first_dose:
			Global.ui.remove_hint()
			first_dose = false
			AfflictionEffectController.first_dose_taken = true
			do_log_entry()
			
		if AfflictionTimer.time_left < AfflictionTimer.MAX_AFFLICTION_TIMER_ALLOW_DRINK:
			num_doses -= 1
			if num_doses > 0:
				var doses_left_string: String = ("Contains %d " % num_doses) + ("dose" if num_doses == 1 else "doses")
				Global.ui.show_hint(doses_left_string, -1)
			else:
				Global.ui.remove_hint()
			
			var play_sigh: bool = AfflictionTimer.time_left < 60.0
			
			Global.player.play_sound_one_shot(Global.player.gulp_sound)
			AfflictionTimer.add_time_mins(5.0)
			AfflictionEffectController.set_to_min_effect(2.0)
			
			set_interactable(false)
			await get_tree().create_timer(0.5, false).timeout
			set_interactable(true)
			
			if play_sigh:
				Global.player.play_sound_one_shot(Global.player.sigh_of_relief_sound)
		else:
			Global.ui.show_hint("Drinking any more won't be effective", 3.0)
		
	else:
		Global.ui.show_hint("It's empty", 3.0)


func distillation_started():
	set_interactable(false)
	pour_player.play()
	await pour_player.finished
	done_pouring.emit()
	num_doses += 1
	set_interactable(true)


func do_log_entry():
	await get_tree().create_timer(2.0, false).timeout
	JournalManager.add_log_entry(LogEntry.LogEntryName.FIRST_DOSE)


func get_save_properties():
	var props: Array[String] = super()
	props.append_array([
		"num_doses",
		"first_dose",
	])
	return props
