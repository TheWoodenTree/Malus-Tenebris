extends Interactable

signal done_pouring

var num_doses: int = 1
var first_dose: bool = true

@onready var pour_player = $PourPlayer


func _on_target():
	if num_doses > 0:
		if not first_dose:
			var doses_left_string: String = ("Contains %d " % num_doses) + ("dose" if num_doses == 1 else "doses")
			Global.ui.hint_popup(doses_left_string, -1)
		else:
			Global.ui.hint_popup("Contains a dose of a temporary inhibitor for Vitriscet", -1)


func _on_untarget():
	Global.ui.hint_remove()


func _on_interact() -> void:
	if first_dose:
		Global.ui.hint_remove()
		first_dose = false
		AfflictionEffectController.first_dose_taken = true
		do_log_entry()
		
	if num_doses > 0:
		if AfflictionTimer.time_left < AfflictionTimer.MAX_AFFLICTION_TIMER_ALLOW_DRINK:
			num_doses -= 1
			if num_doses > 0:
				var doses_left_string: String = ("Contains %d " % num_doses) + ("dose" if num_doses == 1 else "doses")
				Global.ui.hint_popup(doses_left_string, -1)
			else:
				Global.ui.hint_remove()
			
			var play_sigh: bool = AfflictionTimer.time_left < 60.0
			
			Global.player.play_sound_one_shot(Global.player.gulp_sound)
			AfflictionTimer.add_time_mins(1.0)
			AfflictionEffectController.set_to_min_effect(2.0)
			
			set_interactable(false)
			await get_tree().create_timer(0.5, false).timeout
			set_interactable(true)
			
			if play_sigh:
				Global.player.play_sound_one_shot(Global.player.sigh_of_relief_sound)
		else:
			Global.ui.hint_popup("Drinking any more won't be effective", 3.0)
		
	else:
		Global.ui.hint_popup("It's empty", 3.0)


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
