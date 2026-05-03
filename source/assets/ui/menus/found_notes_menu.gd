extends Menu

signal new_note_added(note_button: Button, note_data: NoteData)

const FOUND_NOTE_ROW = preload("uid://cyar0lqn7nke0")

var row_count: int = 0
var rows: Array[FoundNoteRow]

@onready var rows_cont = $Cont/ScrollCont/RowsCont
@onready var tutorial_label = $Cont/TutorialLabel


func _enter_tree():
	if not is_node_ready():
		await ready # Allow onready var to be assigned for the first time
	
	for note_data: NoteData in JournalManager.found_notes:
		var row_exists := false
		for row: FoundNoteRow in rows_cont.get_children():
			if row.note_data == note_data:
				row_exists = true
				break
		
		if not row_exists:
			_add_note(note_data)


func _ready() -> void:
	tutorial_label.visible = JournalManager.show_note_tutorial


func _add_note(note_data: NoteData):
	var new_row: FoundNoteRow = FOUND_NOTE_ROW.instantiate()
	new_row.note_data = note_data
	rows_cont.add_child(new_row)
	rows_cont.move_child(new_row, 0)
	
	if not new_row.is_node_ready():
		await new_row.ready
		
	var button: FoundNoteButton = new_row.found_note_button
	button.pressed.connect(turn_off_tutorial)
	rows.append(new_row)
	row_count += 1
	new_note_added.emit(button, note_data)


func turn_off_tutorial():
	JournalManager.show_note_tutorial = false
	tutorial_label.visible = false
