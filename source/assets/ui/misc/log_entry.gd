@tool
class_name LogEntry
extends Label

enum LogEntryName {
	ESCAPE_START_CELL, FIND_TORCH, TEST, SPRINT
}

var log_entry_dict: Dictionary = {
	LogEntryName.ESCAPE_START_CELL: "Find a way to escape the cell",
	LogEntryName.FIND_TORCH: "Find a torch",
	LogEntryName.TEST: "This is a test log entry",
	LogEntryName.SPRINT: "You've sprinted for the very first time in your life",
}

@export var hint_name: LogEntryName : set = set_hint_name


func _ready():
	text = "- " + log_entry_dict[hint_name]


func set_hint_name(log_entry_name: LogEntryName):
	hint_name = log_entry_name
	text = "- " + log_entry_dict[hint_name]
