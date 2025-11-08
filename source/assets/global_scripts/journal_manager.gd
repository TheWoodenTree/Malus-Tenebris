extends Node

var log_entries: Array[LogEntry.LogEntryName] = []
var found_notes: Dictionary[String, String] = {}

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()
@onready var show_note_tutorial: bool = not Global.player.debug_no_tutorials


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String


func add_log_entry(log_entry_name: LogEntry.LogEntryName):
	if log_entries.has(LogEntry.LogEntryName.PICKED_UP_JOURNAL):
		remove_log_entry(LogEntry.LogEntryName.PICKED_UP_JOURNAL)
	log_entries.append(log_entry_name)
	Global.ui.notify_new_log_entry()


func remove_log_entry(log_entry_name: LogEntry.LogEntryName):
	if log_entries.is_empty():
		push_error("Tried remove an log entry when there are none")
		return
	
	if log_entries.has(log_entry_name):
		log_entries.erase(log_entry_name)
	else:
		push_error("Tried remove an log entry when there are none")


func add_note(note_name: String, note_text: String):
	found_notes[note_name] = note_text
	#Global.found_notes.add_note(note_name, note_text)


func has_log_entry(log_entry_name: LogEntry.LogEntryName) -> bool:
	return log_entries.has(log_entry_name)


func get_save_properties():
	return [
		"log_entries",
		"found_notes",
		"show_note_tutorial",
	] as Array[String]
