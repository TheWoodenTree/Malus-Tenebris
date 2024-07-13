extends Menu

signal new_note_added(note_button: Button, note_text: String)

var button_count: int = 0
var buttons: Array[Control]
var queued_method_calls: Array[Callable]
var button_res: Resource = preload("res://source/assets/ui/buttons/iconless_button.tscn")

@onready var buttons_cont = $cont/scroll_cont/buttons_cont
@onready var tutorial_label = $cont/tutorial_label


func _enter_tree():
	if not is_node_ready():
		await ready # Allow onready var to be assigned for the first time
		
	while queued_method_calls.size() > 0:
		var callable: Callable = queued_method_calls.pop_front()
		callable.call()


func _ready():
	tutorial_label.visible = not Global.player.debug_no_tutorials


func add_note(note_name: String, note_text: String, _delayed_call: bool = false):
	if is_inside_tree():
		var new_button: Control = button_res.instantiate()
		new_button.text = note_name
		new_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		new_button.pressed.connect(turn_off_tutorial)
		buttons.append(new_button)
		buttons_cont.add_child(new_button)
		buttons_cont.move_child(new_button, 0)
		button_count += 1
		new_note_added.emit(new_button, note_text)
	else:
		queued_method_calls.append(add_note.bind(note_name, note_text, true))
	
	#if not delayed_call: # New log entry should not be played again when menu is opened method is called again
	#	Global.ui.hint_popup("New log entry", 3.0)
	#	Global.ui.generic_audio_player.play()


func turn_off_tutorial():
	tutorial_label.visible = false
