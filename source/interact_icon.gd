extends TextureRect

var door_rotating_icon = preload("res://source/assets/ui/interact_icons/interact_door_rotate.png")
var rotate_arrow_icon = preload("res://source/assets/ui/interact_icons/interact_drag_arrow.png")
var rotate_arrow_hand_icon = preload("res://source/assets/ui/interact_icons/interact_drag_arrow_hand.png")
var box_move_icon = preload("res://source/assets/ui/interact_icons/box_move.png")
var insert_key_icon = preload("res://source/assets/ui/interact_icons/interact_insert_key.png")
var eye_icon = preload("res://source/assets/ui/interact_icons/interact_eye.png")
var grabbing_hand_icon = preload("res://source/assets/ui/interact_icons/interact_grabbing_hand.png")

var icons_dict: Dictionary = {Interactable.Type.DOOR: grabbing_hand_icon,
							  Interactable.Type.DRAGGABLE: rotate_arrow_hand_icon,
							  Interactable.Type.LOCKED_DOOR: insert_key_icon,
							  Interactable.Type.PICKUP: grabbing_hand_icon,
							  Interactable.Type.NOTE: eye_icon,
							  Interactable.Type.MOVEABLE: grabbing_hand_icon,
							  Interactable.Type.FIRE: grabbing_hand_icon,
							  Interactable.Type.MISC: grabbing_hand_icon}

func _ready():
	Global.player.looked_at_interactable.connect(update_icon)
	Global.player.holding_self_useable.connect(update_icon)
	Global.player.looked_away_from_interactable.connect(set_icon_visible)


func set_icon_visible(player_holding_self_useable: bool = false):
	if not player_holding_self_useable:
		visible = false
	else:
		visible = true
		update_icon(Interactable.Type.NOTE)


func update_icon(interactable_type: Interactable.Type):
	texture = icons_dict[interactable_type]
	visible = true
