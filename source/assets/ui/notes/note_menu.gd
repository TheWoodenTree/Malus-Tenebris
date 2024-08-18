extends Menu

var note # Set by the note object in-game that summons this note screen
var note_name: String
var note_text: String
var page_number_text: String

@onready var note_name_label = $cont/v_box_cont/panel_cont/note_name
@onready var left_button: Button = $cont/v_box_cont/h_box_cont/left_button
@onready var right_button: Button = $cont/v_box_cont/h_box_cont/right_button
@onready var scroll_cont: ScrollContainer = $cont/v_box_cont/scroll_cont


func _enter_tree():
	if not is_node_ready():
		await ready
	
	#scroll_cont.scroll_vertical = 0
	update_note_name()


func _ready():
	set_note_text(note_text)
	left_button.disabled = true
	if note.num_pages == 1:
		right_button.disabled = true


#func _process(_delta):
#	if Input.is_action_just_pressed("right"):
#		note.turn_page(note.FORWARD)
#	elif Input.is_action_just_pressed("left"):
#		note.turn_page(note.BACKWARD)


func set_note_text(text):
	note_text = text
	$cont/v_box_cont/scroll_cont/text.text = note_text


func update_note_name():
	note_name_label.text = note_name


func set_page_number_text(text):
	page_number_text = text
	$cont/v_box_cont/h_box_cont/page_number.text = page_number_text


func _on_close_button_pressed():
	Global.ui.remove_menu()


func _on_left_button_pressed():
	note.turn_page(note.BACKWARD)


func _on_right_button_pressed():
	note.turn_page(note.FORWARD)
