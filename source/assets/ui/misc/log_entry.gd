@tool
class_name LogEntry
extends HBoxContainer

enum LogEntryName {
	PICKED_UP_JOURNAL, ESCAPE_START_CELL, FIND_TORCH, TEST, SPRINT, FIRST_DOSE
}

var log_entry_dict: Dictionary = {
	LogEntryName.PICKED_UP_JOURNAL: "Useful information will be written here and notes found throughout the prison will be kept in the Found Notes tab",
	LogEntryName.ESCAPE_START_CELL: "Find a way to escape the cell",
	LogEntryName.FIND_TORCH: "Find a torch",
	LogEntryName.TEST: "This is a test log entry",
	LogEntryName.SPRINT: "You've sprinted for the very first time in your life, congratulations on your achievement",
	LogEntryName.FIRST_DOSE: "Find and distill more Ruboleum to stop the onset of Vitriscet",
}

@export var hint_name: LogEntryName : set = set_hint_name
@onready var text_label = $text_label

func _ready():
	text_label.text = log_entry_dict[hint_name]


func set_hint_name(log_entry_name: LogEntryName):
	hint_name = log_entry_name
	if text_label:
		text_label.text = log_entry_dict[hint_name]
