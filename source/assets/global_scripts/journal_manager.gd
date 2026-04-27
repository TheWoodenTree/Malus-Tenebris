extends Node

var log_entries: Array[LogEntry.LogEntryName] = []
var found_notes: Array[NoteData]

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()
@onready var show_note_tutorial: bool = not Global.player.debug_no_tutorials
@onready var auto_open_to_read_timer := Timer.new()


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String
	
	add_child(auto_open_to_read_timer)
	auto_open_to_read_timer.wait_time = 3.0
	auto_open_to_read_timer.one_shot = true


func _process(_delta: float) -> void:
	if not auto_open_to_read_timer.is_stopped() and Input.is_action_just_pressed("read_now"):
		Global.player.hold_item(InventoryManager.items.values().filter(func(item_data): return item_data.name == "Old Journal")[0])
		#Global.ui.display_menu(Global.ui.journal_menu)


func add_log_entry(log_entry_name: LogEntry.LogEntryName):
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


func add_note(note_data: NoteData):
	found_notes.append(note_data)
	auto_open_to_read_timer.start()


func has_log_entry(log_entry_name: LogEntry.LogEntryName) -> bool:
	return log_entries.has(log_entry_name)


func get_save_properties():
	return [
		"log_entries",
		"found_notes",
		"show_note_tutorial",
	] as Array[String]
