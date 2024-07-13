extends MeshInstance3D


func _enter_tree():
	await get_tree().create_timer(0.35, false).timeout
	Global.ui.display_menu(Global.ui.journal_menu)
