class_name FoundNoteButton
extends IconlessButton

var note_data: NoteData


func _ready():
	super()


func _on_mouse_entered() -> void:
	super()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_position", Vector2.RIGHT * 10, 0.2)


func _on_mouse_exited() -> void:
	super()
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "offset_transform_position", Vector2.ZERO, 0.2)
