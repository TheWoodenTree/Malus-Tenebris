extends Menu

var entry_count: int = 0
var entries: Array[Control]
var queued_method_calls: Array[Callable]
var entry_res: Resource = preload("res://source/assets/ui/misc/log_entry.tscn")

@onready var entries_cont = $cont/v_box_cont/entries_cont


func _enter_tree():
	if not is_node_ready():
		await ready # Allow onready var to be assigned for the first time
		
	while queued_method_calls.size() > 0:
		var callable: Callable = queued_method_calls.pop_front()
		callable.call()


func _ready():
	add_entry(LogEntry.LogEntryName.ESCAPE_START_CELL)


func add_entry(log_entry_name: LogEntry.LogEntryName, delayed_call: bool = false):
	if is_inside_tree():
		var new_entry: LogEntry = entry_res.instantiate()
		new_entry.set_hint_name(log_entry_name)
		entries.append(new_entry)
		entries_cont.add_child(new_entry)
		entries_cont.move_child(new_entry, 0)
		entry_count += 1
	else:
		queued_method_calls.append(add_entry.bind(log_entry_name, true))
	
	if not delayed_call: # New log entry should not be played again when menu is opened method is called again
		Global.ui.hint_popup("New log entry", 3.0)
		Global.ui.generic_audio_player.play()


func remove_entry(log_entry_name: LogEntry.LogEntryName):
	if is_inside_tree():
		if entry_count > 0:
			for log_entry: LogEntry in entries:
				if log_entry.hint_name == log_entry_name:
					entries_cont.remove_child(log_entry)
					entries.erase(log_entry)
					return
			push_error("Tried to remove log entry which is not in the journal")
		else:
			push_error("Tried remove an log entry when there are none")
	else:
		queued_method_calls.append(remove_entry.bind(log_entry_name))
	
