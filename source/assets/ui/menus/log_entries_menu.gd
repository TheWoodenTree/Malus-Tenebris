extends Menu

var entry_count: int = 0
var entries: Array[Control]
var entry_res: Resource = preload("res://source/assets/ui/misc/log_entry.tscn")

@onready var entries_cont = $Cont/VBoxCont/ScrollCont/EntriesCont


func _enter_tree():
	if not is_node_ready():
		await ready # Allow onready var to be assigned for the first time
	
	for log_entry_name: LogEntry.LogEntryName in JournalManager.log_entries:
		var log_entry_exists := false
		for existing_entry: LogEntry in entries_cont.get_children():
			if existing_entry.hint_name == log_entry_name:
				log_entry_exists = true
				break
			existing_entry.queue_free()
		
		if not log_entry_exists:
			_add_entry(log_entry_name)


func _add_entry(log_entry_name: LogEntry.LogEntryName):
	var new_entry: LogEntry = entry_res.instantiate()
	new_entry.set_hint_name(log_entry_name)
	entries.append(new_entry)
	entries_cont.add_child(new_entry)
	entries_cont.move_child(new_entry, 0)
	entry_count += 1
