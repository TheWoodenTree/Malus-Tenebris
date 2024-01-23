extends Area3D

var player_entered_area: bool = false


func _on_body_entered(body):
	if body == Global.player and Global.player.first_item_picked_up and not player_entered_area:
		Global.ui.hint_popup("Press 'E' to open your inventory", 5.0)
		Global.ui.block_inventory_open = false
		player_entered_area = true
