class_name ResolveLogEntryEvent
extends Event

@export var log_entry_name: LogEntry.LogEntryName


func _execute() -> void:
	JournalManager.remove_log_entry(log_entry_name)
