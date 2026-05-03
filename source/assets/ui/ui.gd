class_name UI
extends CanvasLayer

const BLUR_TIME: float = 0.1

var top_open_menu: Control = null

var inventory_menu: Control
var death_screen: Control
var curr_popup: Control
var curr_popup_wr: WeakRef = null

var inventory_open: bool = false

var prologue: Control = preload("res://source/assets/prologue/prologue.tscn").instantiate()
var hint_res: Resource = preload("res://source/assets/ui/hint.tscn")
var hint_popup: HintPopup = preload("res://source/assets/ui/popups/hint_popup.tscn").instantiate()
var death_screen_res: Resource = preload("res://source/assets/ui/death_screen.tscn")
var inventory_menu_res: Resource = preload("res://source/assets/ui/inventory.tscn")
var are_you_sure_menu: AreYouSureMenu = preload("res://source/assets/ui/menus/are_you_sure_menu.tscn").instantiate()
var pause_menu: Control = preload("res://source/assets/ui/menus/pause_menu.tscn").instantiate()
var settings_menu: Control = preload("res://source/assets/ui/menus/settings_menu.tscn").instantiate()
var journal_menu: Control = preload("res://source/assets/ui/menus/journal_menu.tscn").instantiate()
var log_entries_menu: Control = preload("res://source/assets/ui/menus/log_entries_menu.tscn").instantiate()
var found_notes_menu: Control = preload("res://source/assets/ui/menus/found_notes_menu.tscn").instantiate()
var note_menu: Control = preload("res://source/assets/ui/menus/note_menu.tscn").instantiate()
var in_journal_note_menu: Control = preload("res://source/assets/ui/menus/in_journal_note_menu.tscn").instantiate()

@onready var background = $MenuManager/Background
@onready var interact_icon = $Cont/InteractIcon
@onready var menu_manager: MenuManager = $MenuManager
@onready var popup_manager: PopupManager = $PopupManager
@onready var block_inventory_open: bool = false
@onready var generic_audio_player = $GenericAudioPlayer
@onready var hourglass_empty_player: AudioStreamPlayer = $HourglassEmptyPlayer
@onready var inventory_item_sound_player: AudioStreamPlayer = $InventoryItemSoundPlayer
@onready var button_hover_player = $ButtonHoverPlayer
@onready var button_up_player = $ButtonUpPlayer
@onready var button_down_player = $ButtonDownPlayer
@onready var log_entry_notification: HBoxContainer = $Cont/VBoxContainer/LogEntryNotification
@onready var hourglass_empty_notification: MarginContainer = $Cont/HourglassEmptyNotification
@onready var found_note_notification: HBoxContainer = $Cont/VBoxContainer/FoundNoteNotification

signal inventory_opened


func _ready():
	inventory_menu = inventory_menu_res.instantiate()
	death_screen = death_screen_res.instantiate()
	
	AfflictionTimer.timeout.connect(notify_hourglass_empty)
	inventory_menu.item_attached_to_cursor.connect(play_inventory_item_click_sound)
	
	Global.ui = self
	Global.inventory = inventory_menu
	Global.journal_log = log_entries_menu
	Global.found_notes = found_notes_menu


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton:
		if event.is_action_pressed("toggle_inventory"):
			if menu_manager.num_menus == 0:
				open_inventory()
			elif menu_manager.back() == inventory_menu:
				menu_manager.remove_menu()
		
		elif event.is_action_pressed("pause"):
			if menu_manager.open_menus.size() > 0 and menu_manager.back() != Global.main.title_screen:
				if menu_manager.back() == pause_menu:
					get_tree().paused = false
				menu_manager.remove_menu()
			elif Global.player.in_world:
				menu_manager.display_menu(pause_menu)


func remove_hint():
	if curr_popup_wr and curr_popup_wr.get_ref():
		curr_popup.disappear()


func show_hint(msg: String, dur: float):
	var popup = hint_res.instantiate()
	var popup_wr = weakref(popup)
	
	# Free any popup already on screen when this function is called
	if curr_popup_wr and curr_popup_wr.get_ref():
		curr_popup.queue_free()
		
	add_child(popup)
	move_child(popup, 0)
	curr_popup = popup
	curr_popup_wr = weakref(popup)
	popup.appear(msg)
	
	# Return if dur is negative to allow popups that will stay on the screen
	if dur < 0:
		return
	
	await get_tree().create_timer(dur, false).timeout
	
	# Ensure this popup was not freed by another call to this function before
	# this popup frees itself
	if popup_wr and popup_wr.get_ref():
		popup.disappear()


func show_hint_popup(msg: String):
	hint_popup.text = msg
	popup_manager.display_popup(hint_popup)


func open_inventory():
	if not block_inventory_open and not Global.player.in_menu:
		menu_manager.display_menu(inventory_menu)
		inventory_opened.emit()


func display_death_screen():
	if menu_manager.num_menus == 0 and menu_manager.add_menu(death_screen):
		Global.player.in_menu = true


func do_prologue():
	add_child(prologue)


func notify_new_log_entry():
	generic_audio_player.play()
	var tween1: Tween = get_tree().create_tween()
	tween1.tween_property(log_entry_notification, "modulate:a", 1.0, 0.5).from(0.0)
	
	await get_tree().create_timer(7.5, false).timeout
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(log_entry_notification, "modulate:a", 0.0, 0.5).from(1.0)


func notify_new_found_note():
	var tween1: Tween = get_tree().create_tween()
	tween1.tween_property(found_note_notification, "modulate:a", 1.0, 0.5).from(0.0)
	
	await get_tree().create_timer(JournalManager.AUTO_OPEN_TO_READ_TIME, false).timeout
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(found_note_notification, "modulate:a", 0.0, 0.5).from(1.0)


func notify_hourglass_empty():
	if SaveManager.is_loading: # Don't play this on loeading a save with no time left
		return
	
	hourglass_empty_player.play()
	await get_tree().create_timer(1.0, false).timeout
	var tween1: Tween = get_tree().create_tween()
	tween1.tween_property(hourglass_empty_notification, "modulate:a", 1.0, 0.5).from(0.0)
	
	await get_tree().create_timer(7.5, false).timeout
	var tween2: Tween = get_tree().create_tween()
	tween2.tween_property(hourglass_empty_notification, "modulate:a", 0.0, 0.5).from(1.0)


func play_inventory_item_click_sound(item_data: ItemData):
	inventory_item_sound_player.stream = item_data.pickup_sound
	inventory_item_sound_player.play()
