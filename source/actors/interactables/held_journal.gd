extends SelfUseable


func use():
	used = true
	Global.ui.display_menu(Global.ui.journal_menu)
