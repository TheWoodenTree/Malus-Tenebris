extends Pickup


func _on_interact() -> void:
	GlobalSignals.journal_picked_up.emit()
	Global.journal_log.add_entry(LogEntry.LogEntryName.PICKED_UP_JOURNAL)	
