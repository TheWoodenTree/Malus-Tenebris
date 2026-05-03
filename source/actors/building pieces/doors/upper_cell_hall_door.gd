@tool
extends Door

var player_picked_up_journal: bool = not Engine.is_editor_hint() and Global.player.debug_no_tutorials 


func _ready():
	super()
	if not Engine.is_editor_hint():
		GlobalSignals.journal_picked_up.connect(func(): player_picked_up_journal = true)


func _on_interact() -> void:
	if not player_picked_up_journal:
		Global.ui.show_hint("What was that book on the ground?", 3.0)
	else:
		super()
