extends Interactable

const BLUR_TIME = 0.1
const BACKWARD = 0
const FORWARD = 1

const PICKUP_SOUND = preload("uid://joprbalclo82")

@export var display_help: bool = false
@export var note_data: NoteData

var pages: Array
var num_pages: int
var curr_page: int
var raw_text: String

var read: bool = false

@onready var interact_area = $InteractArea
@onready var page_turn_player = $PageTurnPlayer
@onready var mesh = $Mesh

signal was_read


func _ready() -> void:
	super()
	# I shouldn't have to wonder why I have to do this when resource_local_to_scene
	# is checked for the material :) (NOTICE: this may be fixed now, try removing 'fix')
	var note_mat = mesh.mesh.surface_get_material(0)
	mesh.mesh.surface_set_material(0, note_mat.duplicate())
	note_mat = mesh.mesh.surface_get_material(0)
	
	Global.ui.note_menu.note = self


func _on_target():
	if display_help and not read:
		Global.ui.show_hint("Press 'Left Click' to interact with highlighted objects", -1)


func _on_untarget():
	if display_help:
		Global.ui.remove_hint()


func _on_interact() -> void:
	# Minor bug: blur does not go away sometimes if interact and close are spammed
	if not Global.player.in_menu:
		#Global.ui.note_menu.note_data = note_data
		#Global.ui.menu_manager.display_menu(Global.ui.note_menu)
	
		was_read.emit()
		if display_help:
			Global.ui.remove_hint()
		
		if not read:
			JournalManager.add_note(note_data)
		
		read = true
		
		visible = false
		for area: InteractArea in interact_areas:
			area.set_collision_layer_value(16, false)
		
		#Global.ui.show_hint("New note, %s\nCheck your journal" % note_data.title, 3.0)
		Global.ui.notify_new_found_note()
		
		page_turn_player.play()
		await page_turn_player.finished
		
		queue_free()


#DEPRECATED
func turn_page(direction):
	if direction == FORWARD and (curr_page + 1) < num_pages:
		curr_page += 1
	elif direction == BACKWARD and (curr_page - 1) >= 0:
		curr_page -= 1
	else:
		return
		
	if curr_page < (num_pages - 1):
		Global.ui.note_menu.right_button.disabled = false
	else:
		Global.ui.note_menu.right_button.disabled = true
		
	if curr_page > 0: 
		Global.ui.note_menu.left_button.disabled = false
	else:
		Global.ui.note_menu.left_button.disabled = true
		
	page_turn_player.play()
	Global.ui.note_menu.set_note_text(pages[curr_page])
	Global.ui.note_menu.set_page_number_text("Page %d/" % (curr_page + 1) + str(num_pages))
