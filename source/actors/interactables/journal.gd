extends Pickup


func interact():
	GlobalSignals.journal_picked_up.emit()
	super()
