@tool
extends Interactable

@export_multiline var text: String : set = _set_text
@export var font_size: int = 36 : set = _set_font_size
@export var chain_length: int = 2 : set = _set_chain_length

@onready var static_chain_1 = $StaticChain1
@onready var static_chain_2 = $StaticChain2
@onready var label_3d_1: Label3D = $Mesh/Label3D1
@onready var label_3d_2: Label3D = $Mesh/Label3D2


func _ready():
	super()
	update_chains()
	_update_sign_labels()


func _on_target():
	if interactable:
		Global.ui.show_hint(text, -1)
		if enable_highlight_sheen:
			enable_highlight_sheen = false
			disable_sheen()


func _on_untarget():
	Global.ui.remove_hint()


func _on_interact() -> void:
	pass


func _set_chain_length(length: int):
	chain_length = length
	update_chains()


func update_chains():
	if static_chain_1 and static_chain_2:
		if chain_length == 0:
			static_chain_1.visible = false
			static_chain_2.visible = false
		else:
			static_chain_1.visible = true
			static_chain_2.visible = true
			static_chain_1.length = chain_length
			static_chain_2.length = chain_length
			static_chain_1.position.y = 0.75 + chain_length
			static_chain_2.position.y = 0.75 + chain_length


func _set_text(text_: String):
	text = text_
	_update_sign_labels()


func _set_font_size(font_size_: int):
	font_size = font_size_
	_update_sign_labels()


func _update_sign_labels():
	if label_3d_1:
		label_3d_1.text = text
		label_3d_1.font_size = font_size
		
	if label_3d_2:
		label_3d_2.text = text
		label_3d_2.font_size = font_size
