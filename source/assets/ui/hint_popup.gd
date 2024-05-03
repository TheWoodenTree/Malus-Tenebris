extends Control

const POPUP_TRANS_TIME = 0.5

@onready var cont: MarginContainer = $cont
@onready var text = $cont/text
@onready var inst_timer = $inst_timer


func appear(msg):
	text.text = msg
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var offset: int = (text.text.get_slice_count('\n') - 1) * 30
	tween.tween_property(cont, "theme_override_constants/margin_bottom", -250 + offset, POPUP_TRANS_TIME).from(-320 - offset)


func disappear():
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	var offset: int = (text.text.get_slice_count('\n') - 1) * 30
	tween.tween_property(cont, "theme_override_constants/margin_bottom", -320 - offset, POPUP_TRANS_TIME).from(cont.get("theme_override_constants/margin_bottom"))
	tween.tween_callback(queue_free)
