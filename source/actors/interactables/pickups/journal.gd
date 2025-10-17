extends Pickup

var added_to_inventory := false


func _enter_tree():
	if added_to_inventory:
		await get_tree().create_timer(0.35, false).timeout
		Global.ui.display_menu(Global.ui.journal_menu)


func _on_interact() -> void:
	added_to_inventory = true
	super()
	GlobalSignals.journal_picked_up.emit()
	Global.journal_log.add_entry(LogEntry.LogEntryName.PICKED_UP_JOURNAL)
