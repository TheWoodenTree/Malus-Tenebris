extends Menu

var note # Set by the note object in-game that summons this note screen
var note_data: NoteData

@onready var note_name_label = $Cont/VBoxCont/PanelCont/NoteName
@onready var scroll_cont: ScrollContainer = $Cont/VBoxCont/ScrollCont
@onready var text_label: Label = $Cont/VBoxCont/ScrollCont/Text


func _enter_tree():
	if not is_node_ready():
		await ready
	
	scroll_cont.scroll_vertical = 0
	update()


#func _process(_delta):
#	if Input.is_action_just_pressed("right"):
#		note.turn_page(note.FORWARD)
#	elif Input.is_action_just_pressed("left"):
#		note.turn_page(note.BACKWARD)


func update():
	note_name_label.text = note_data.title
	text_label.text = note_data.text


func _on_close_button_pressed():
	Global.ui.remove_menu()


func _on_left_button_pressed():
	note.turn_page(note.BACKWARD)


func _on_right_button_pressed():
	note.turn_page(note.FORWARD)
