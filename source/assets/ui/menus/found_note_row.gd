class_name FoundNoteRow
extends HBoxContainer

var note_data: NoteData

@onready var important_icon: TextureRect = $ImportantIcon
@onready var found_note_button: FoundNoteButton = $FoundNoteButton


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	
	important_icon.modulate = Color.TRANSPARENT if note_data.was_read else Color.WHITE


func _ready() -> void:
	found_note_button.text = note_data.title
