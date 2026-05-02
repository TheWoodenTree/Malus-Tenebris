class_name GreatDoorCloseEvent
extends Event


func _execute() -> void:
	GlobalSignals.emit_signal("great_door_close_area_entered")
	await Global.get_tree().create_timer(7.0, false).timeout
	JournalManager.add_log_entry(LogEntry.LogEntryName.GREAT_DOOR_CLOSED)
