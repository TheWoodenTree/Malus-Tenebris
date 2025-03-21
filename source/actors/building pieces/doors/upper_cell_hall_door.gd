@tool
extends Door

var player_picked_up_journal: bool = Global.player.debug_no_tutorials and not Engine.is_editor_hint()


func _ready():
	super()
	if not Engine.is_editor_hint():
		GlobalSignals.journal_picked_up.connect(func(): player_picked_up_journal = true)


func interact():
	if player_picked_up_journal:
		super()
	else:
		Global.ui.hint_popup("What was that book on the ground?", 3.0)
