extends Interactable

const BLUR_TIME = 0.1
const BACKWARD = 0
const FORWARD = 1

var pages: Array
var num_pages: int
var curr_page: int
var raw_text: String

var read: bool = false

var note_screen = preload("res://source/assets/ui/note_menu.tscn").instantiate()

@export var display_help: bool = false
@export var label: PackedScene

@onready var mesh = $mesh
@onready var interact_area = $interact_area
@onready var page_turn_player = $page_turn_player
@onready var note_mat = mesh.mesh.surface_get_material(0)
@onready var base_color = note_mat.albedo_color

signal was_read


func _ready() -> void:
	init(Type.NOTE, interact_area)
	# I shouldn't have to wonder why I have to do this when resource_local_to_scene
	# is checked for the material :)
	mesh.mesh.surface_set_material(0, note_mat.duplicate())
	note_mat = mesh.mesh.surface_get_material(0)
	
	note_screen.note = self
	raw_text = label.instantiate().text
	pages = raw_text.split("\n[PAGE]\n")
	num_pages = pages.size()
	curr_page = 0
	note_screen.set_note_text(pages[curr_page])
	note_screen.set_page_number_text("Page 1/" + str(num_pages))


func _process(_delta: float) -> void:
	# Enable interaction outline if being looked at
	if being_looked_at:
		if display_help and not Global.player.in_menu and not outline_on and not read:
			Global.ui.hint_popup("Press 'Left Mouse' to interact with highlighted objects", -1)
		if mesh.material_overlay and not outline_on:
			mesh.material_overlay.set_shader_parameter("outlineOn", true)
		outline_on = true
	elif outline_on:
		Global.ui.hint_remove()
		if mesh.material_overlay:
			mesh.material_overlay.set_shader_parameter("outlineOn", false)
		outline_on = false


func interact():
	# Minor bug: blur does not go away sometimes if interact and close are spammed
	if interactable and not Global.player.in_menu:
		page_turn_player.play()
		Global.ui.set_blur_background(true)
		
		Global.player.in_menu = true
		Global.ui.add_child(note_screen)
		Global.unlock_mouse()
	
		read = true
		emit_signal("was_read")
		if display_help:
			Global.ui.hint_remove()


func remove_note_screen():
	page_turn_player.play()
	Global.ui.set_blur_background(false)
	
	await Global.ui.background_changed
	
	Global.player.in_menu = false
	Global.ui.remove_child(note_screen)
	Global.lock_mouse()


func turn_page(direction):
	if direction == FORWARD and (curr_page + 1) < num_pages:
		curr_page += 1
	elif direction == BACKWARD and (curr_page - 1) >= 0:
		curr_page -= 1
	else:
		return
		
	if curr_page < (num_pages - 1):
		note_screen.right_button.disabled = false
	else:
		note_screen.right_button.disabled = true
		
	if curr_page > 0: 
		note_screen.left_button.disabled = false
	else:
		note_screen.left_button.disabled = true
		
	page_turn_player.play()
	note_screen.set_note_text(pages[curr_page])
	note_screen.set_page_number_text("Page %d/" % (curr_page + 1) + str(num_pages))
