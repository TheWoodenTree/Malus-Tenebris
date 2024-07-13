extends Menu

@export var navigation_sound: AudioStream

@onready var log_entries_button = $cont/v_box_cont/cont/panel_cont/h_box_cont/log_entries_button
@onready var v_sep_1 = $cont/v_box_cont/cont/panel_cont/h_box_cont/v_sep_1
@onready var found_notes_button = $cont/v_box_cont/cont/panel_cont/h_box_cont/found_notes_button
@onready var submenu_cont = $cont/v_box_cont/submenu_cont


func _ready():
	Global.ui.found_notes_menu.new_note_added.connect(connect_note_button)
	Global.ui.in_journal_note_menu.back_button_pressed.connect(change_menu.bind(Global.ui.found_notes_menu))
	log_entries_button.visible = Global.player.debug_no_tutorials
	v_sep_1.visible = Global.player.debug_no_tutorials
	submenu_cont.add_child(Global.ui.found_notes_menu)
	found_notes_button.select()


func _exit_tree():
	if Global.player.is_holding_item("Old Journal"):
		Global.player.stop_holding_item(false)


func _on_log_entries_button_pressed():
	change_menu(Global.ui.log_entries_menu)
	log_entries_button.select()
	found_notes_button.deselect()


func _on_found_notes_button_pressed():
	change_menu(Global.ui.found_notes_menu)
	found_notes_button.select()
	log_entries_button.deselect()


func connect_note_button(note_button: Button, note_text: String):
	note_button.pressed.connect(note_button_pressed.bind(note_text))


func note_button_pressed(note_text: String):
	Global.ui.in_journal_note_menu.note_text = note_text.replacen("[PAGE]", "")
	#Global.ui.in_journal_note_menu.set_page_number_text("Page 1/" + str(3))
	change_menu(Global.ui.in_journal_note_menu)


func change_menu(menu: Menu):
	if submenu_cont.get_child_count() > 0:
		for child in submenu_cont.get_children():
			submenu_cont.remove_child.call_deferred(child)
	submenu_cont.add_child.call_deferred(menu)
	Global.ui.menus.play_sound_one_shot(navigation_sound)
