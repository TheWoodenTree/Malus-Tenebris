extends Menu

signal back_button_pressed

var note_data: NoteData

@onready var note_text_label: Label = $Cont/VBoxCont/ScrollCont/Text
@onready var scroll_cont = $Cont/VBoxCont/ScrollCont
@onready var note_name: Label = $Cont/VBoxCont/HBoxContainer/PanelCont/NoteName
@onready var back_button: IconlessButton = $Cont/VBoxCont/BackButton


func _enter_tree():
	if not is_node_ready():
		await ready
	
	scroll_cont.scroll_vertical = 0
	note_name.text = note_data.title
	note_text_label.text = note_data.text


func _ready() -> void:
	back_button.pressed.connect(func(): back_button_pressed.emit())
