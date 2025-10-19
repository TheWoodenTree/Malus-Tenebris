extends Pickup


func _enter_tree():
	if being_held:
		await get_tree().create_timer(0.35, false).timeout
		Global.ui.display_menu(Global.ui.journal_menu)


func _on_interact() -> void:
	super()
	GlobalSignals.journal_picked_up.emit()
	JournalManager.add_log_entry(LogEntry.LogEntryName.PICKED_UP_JOURNAL)
