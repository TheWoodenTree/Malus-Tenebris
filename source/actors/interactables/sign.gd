@tool
extends Interactable

@export_multiline var text: String
@export var chain_length: int = 2 : set = _set_chain_length

@onready var mesh = $mesh
@onready var interact_area = $interact_area
@onready var static_chain_1 = $static_chain1
@onready var static_chain_2 = $static_chain2


func _ready():
	update_chains()
	if not Engine.is_editor_hint():
		init(Type.NOTE, interact_area, [mesh])


func _process(_delta):
	if not Engine.is_editor_hint():
		if interactable and being_looked_at:
			if not outline_on:
				Global.ui.hint_popup(text, -1)
				if enable_highlight_sheen:
					enable_highlight_sheen = false
					disable_sheen()
			outline_on = true
		elif outline_on:
			Global.ui.hint_remove()
			outline_on = false


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
	
