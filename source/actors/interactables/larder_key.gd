extends Pickup


func interact():
	if interactable and not Global.player.held_item_data:
		Global.player.picked_up_larder_key = true
	super()
