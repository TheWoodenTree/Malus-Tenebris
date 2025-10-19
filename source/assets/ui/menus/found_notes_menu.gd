extends Menu

signal new_note_added(note_button: Button, note_text: String)

var button_count: int = 0
var buttons: Array[Control]
var button_res: Resource = preload("res://source/assets/ui/buttons/iconless_button.tscn")

@onready var buttons_cont = $Cont/ScrollCont/ButtonsCont
@onready var tutorial_label = $Cont/TutorialLabel


func _enter_tree():
	if not is_node_ready():
		await ready # Allow onready var to be assigned for the first time
	
	for note_name: String in JournalManager.found_notes.keys():
		var button_exists := false
		for button: Button in buttons_cont.get_children():
			if button.text == note_name:
				button_exists = true
				break
		
		if not button_exists:
			_add_note(note_name, JournalManager.found_notes[note_name])


func _ready() -> void:
	tutorial_label.visible = JournalManager.show_note_tutorial


func _add_note(note_name: String, note_text: String):
	var new_button: Control = button_res.instantiate()
	new_button.text = note_name
	new_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	new_button.pressed.connect(turn_off_tutorial)
	buttons.append(new_button)
	buttons_cont.add_child(new_button)
	buttons_cont.move_child(new_button, 0)
	button_count += 1
	new_note_added.emit(new_button, note_text)


func turn_off_tutorial():
	JournalManager.show_note_tutorial = false
	tutorial_label.visible = false
