extends Pickup


func _on_interact():
	super()
	GameState.set_flag(GameState.Flag.PICKED_UP_CELL_HALL_KEY)
