@tool
extends Interactable

@export_multiline var text: String
@export var chain_length: int = 2 : set = _set_chain_length

@onready var static_chain_1 = $StaticChain1
@onready var static_chain_2 = $StaticChain2


func _ready():
	super()
	update_chains()


func _on_target():
	if interactable:
		Global.ui.hint_popup(text, -1)
		if enable_highlight_sheen:
			enable_highlight_sheen = false
			disable_sheen()


func _on_untarget():
	Global.ui.hint_remove()


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
	
