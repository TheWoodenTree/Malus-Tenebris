extends Node

const AUTO_OPEN_TO_READ_TIME = 8.5

var log_entries: Array[LogEntry.LogEntryName] = []
var found_notes: Array[NoteData]

var recent_note_data: NoteData
var use_recent_note_data: bool = false

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()
@onready var show_note_tutorial: bool = not Global.player.debug_no_tutorials
@onready var auto_open_to_read_timer := Timer.new()


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String
	
	add_child(auto_open_to_read_timer)
	auto_open_to_read_timer.wait_time = AUTO_OPEN_TO_READ_TIME
	auto_open_to_read_timer.one_shot = true
	auto_open_to_read_timer.timeout.connect(func(): recent_note_data = null; use_recent_note_data = false)
	
	await get_tree().process_frame
	print(JournalManager.found_notes.map(func(note_data: NoteData): return note_data.was_read))


func _process(_delta: float) -> void:
	if not auto_open_to_read_timer.is_stopped() and Input.is_action_just_pressed("read_now"):
		use_recent_note_data = true
		Global.player.hold_item(ItemRegistry.item_data_resources[ItemRegistry.ID.JOURNAL])


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
	recent_note_data = note_data
	auto_open_to_read_timer.start()


func has_log_entry(log_entry_name: LogEntry.LogEntryName) -> bool:
	return log_entries.has(log_entry_name)


func get_save_properties():
	return [
		"log_entries",
		"found_notes",
		"show_note_tutorial",
	] as Array[String]
