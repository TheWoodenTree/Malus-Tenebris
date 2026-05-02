class_name LogEntryEvent
extends Event

@export var log_entry_name: LogEntry.LogEntryName


func _execute() -> void:
	JournalManager.add_log_entry(log_entry_name)
