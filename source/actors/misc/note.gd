extends Interactable

const BLUR_TIME = 0.1
const BACKWARD = 0
const FORWARD = 1

@export var display_help: bool = false
@export var note_name: String = "Note"
@export var label: PackedScene

var pages: Array
var num_pages: int
var curr_page: int
var raw_text: String

var read: bool = false

@onready var interact_area = $interact_area
@onready var page_turn_player = $page_turn_player
@onready var mesh = $mesh

signal was_read


func _ready() -> void:
	super()
	init(Type.NOTE, interact_area, [mesh])
	# I shouldn't have to wonder why I have to do this when resource_local_to_scene
	# is checked for the material :) (NOTICE: this may be fixed now, try removing 'fix')
	var note_mat = mesh.mesh.surface_get_material(0)
	mesh.mesh.surface_set_material(0, note_mat.duplicate())
	note_mat = mesh.mesh.surface_get_material(0)
	
	Global.ui.note_menu.note = self
	raw_text = label.instantiate().text
	pages = raw_text.split("\n[PAGE]\n")
	num_pages = pages.size()
	curr_page = 0


func _process(_delta: float) -> void:
	# Enable interaction outline if being looked at
	if being_looked_at:
		if display_help and not read and not outline_on:
			Global.ui.hint_popup("Press 'Left Click' to interact with highlighted objects", -1)
		if shader_mode == "Outline" and mesh.material_overlay and not outline_on:
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
		elif shader_mode == "Highlight" and not mesh.material_override:
			mesh.material_override = highlight_material
		outline_on = true
	elif outline_on:
		if display_help:
			Global.ui.hint_remove()
		if shader_mode == "Outline" and mesh.material_overlay:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)
		elif shader_mode == "Highlight" and mesh.material_override:
			mesh.material_override = null
		outline_on = false


func interact():
	# Minor bug: blur does not go away sometimes if interact and close are spammed
	if interactable and not Global.player.in_menu:
		super()
		
		Global.ui.note_menu.set_note_text(pages[curr_page])
		Global.ui.note_menu.note_name = note_name
		Global.ui.note_menu.set_page_number_text("Page 1/" + str(num_pages))
		Global.ui.display_menu(Global.ui.note_menu)
	
		was_read.emit()
		if display_help:
			Global.ui.hint_remove()
		
		if not read:
			Global.found_notes.add_note(note_name, raw_text.replacen("[PAGE]", ""))
		
		read = true


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
