@tool
class_name LogEntry
extends HBoxContainer

enum LogEntryName {
	TEST, PICKED_UP_JOURNAL, FIRST_DOSE, FIND_SUMP_KEY
}

var log_entry_dict: Dictionary = {
	LogEntryName.TEST: "This is a test log entry",
	LogEntryName.PICKED_UP_JOURNAL: "Useful information will be written here and notes found throughout the prison will be kept in the Found Notes tab",
	LogEntryName.FIRST_DOSE: "Find and distill more Ruboleum to stop the onset of Vitriscet",
	LogEntryName.FIND_SUMP_KEY: "Find the key and access the Sump Tunnels",
}

@export var hint_name: LogEntryName : set = set_hint_name
@onready var text_label = $TextLabel

func _ready():
	text_label.text = log_entry_dict[hint_name]


func set_hint_name(log_entry_name: LogEntryName):
	hint_name = log_entry_name
	if text_label:
		text_label.text = log_entry_dict[hint_name]
