extends Door

var player_picked_up_journal: bool = false or Global.player.debug_no_tutorials


func _ready():
	GlobalSignals.journal_picked_up.connect(func(): player_picked_up_journal = true)
	super()


func interact():
	if player_picked_up_journal:
		super()
	else:
		Global.ui.hint_popup("What was that book on the ground?", 3.0)
