extends Menu

@export var navigation_sound: AudioStream

var current_submenu: Menu

@onready var log_entries_button = $Cont/VBoxCont/Cont/PanelCont/HBoxCont/LogEntriesButton
@onready var v_sep_1 = $Cont/VBoxCont/Cont/PanelCont/HBoxCont/VSep1
@onready var found_notes_button = $Cont/VBoxCont/Cont/PanelCont/HBoxCont/FoundNotesButton
@onready var submenu_cont = $Cont/VBoxCont/SubmenuCont


func _enter_tree() -> void:
	if not is_node_ready():
		await ready
	
	var has_log_entries: bool = JournalManager.log_entries.size() > 0
	log_entries_button.visible = has_log_entries
	v_sep_1.visible = has_log_entries
	
	if JournalManager.recent_note_data and JournalManager.use_recent_note_data:
		if not found_notes_button.selected:
			found_notes_button.pressed.emit()
		note_button_pressed(JournalManager.recent_note_data)
		JournalManager.use_recent_note_data = false
	
	elif current_submenu == Global.ui.in_journal_note_menu:
		change_menu(Global.ui.found_notes_menu)


func _ready():
	Global.ui.found_notes_menu.new_note_added.connect(connect_note_button)
	Global.ui.in_journal_note_menu.back_button_pressed.connect(change_menu.bind(Global.ui.found_notes_menu))
	submenu_cont.add_child(Global.ui.found_notes_menu)
	found_notes_button.select()


func _exit_tree():
	if Global.player.is_holding_item(ItemRegistry.ID.JOURNAL):
		Global.player.stop_holding_item(false)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("journal"):
		Global.ui.remove_menu()


func _on_log_entries_button_pressed():
	change_menu(Global.ui.log_entries_menu)
	log_entries_button.select()
	found_notes_button.deselect()


func _on_found_notes_button_pressed():
	change_menu(Global.ui.found_notes_menu)
	found_notes_button.select()
	log_entries_button.deselect()


func connect_note_button(note_button: Button, note_data: NoteData):
	note_button.pressed.connect(note_button_pressed.bind(note_data))


func note_button_pressed(note_data: NoteData):
	Global.ui.in_journal_note_menu.note_data = note_data
	note_data.was_read = true
	
	if note_data.title == "Cell Note":
		GlobalSignals.cell_note_read.emit()
	
	change_menu(Global.ui.in_journal_note_menu)


func change_menu(menu: Menu):
	if submenu_cont.get_child_count() > 0:
		for child in submenu_cont.get_children():
			submenu_cont.remove_child.call_deferred(child)
	submenu_cont.add_child.call_deferred(menu)
	current_submenu = menu
	Global.ui.menus.play_sound_one_shot(navigation_sound)
