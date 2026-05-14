extends Control

const POPUP_TRANS_TIME = 0.5

@onready var cont: MarginContainer = $Cont
@onready var text: Label = $Cont/Text
@onready var inst_timer = $InstTimer


func appear(msg):
	text.text = msg
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var extra_offset: int = (text.text.get_slice_count('\n') - 1) * 30
	tween.tween_property(text, "offset_transform_position:y", -10, POPUP_TRANS_TIME).from(30 + extra_offset)


func disappear():
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var extra_offset: int = (text.text.get_slice_count('\n') - 1) * 30
	tween.tween_property(text, "offset_transform_position:y", 30 + extra_offset, POPUP_TRANS_TIME).from(text.offset_transform_position.y)
	tween.tween_callback(queue_free)
