extends Node

######################
## GLOBAL VARIABLES ##
######################
var world: Node3D
var world_environment: WorldEnvironment
var nav_region: NavigationRegion3D
var post_processing: PostProcessing
var retro_shader: Material
var chromatic_abberation_shader: Material
var vignette_shader: Material
var zoom_shader: Material
var blackout_blur_shader: Material
var ui: Control
var inventory: Control
var journal_log: Control
var found_notes: Control
var cursor: Node2D
var torch: PlayerTorch
var camera_controller: Node3D
var camera: Node3D

var mouse_sens: float = 0.4
var mouse_locked: bool

var monster: CharacterBody3D

@onready var main: Node = get_tree().root.get_node("Main")
@onready var player: Player = load("res://source/actors/characters/player/player.tscn").instantiate()


#Init Globals
func _ready() -> void:
	main.connect("world_ready", func(): world = main.get_node("World"); monster = world.get_node("Monster"); nav_region = world.get_node('NavRegion'))
	world_environment = main.get_node("WorldEnvironment")
	post_processing = main.get_node("PostProcessing")
	if post_processing != null:
		retro_shader = post_processing.get_node("RetroShader").material
		chromatic_abberation_shader = post_processing.get_node("ChromaticAbberation").material
		vignette_shader = post_processing.get_node("Vignette").material
		zoom_shader = post_processing.get_node("Zoom").material
		blackout_blur_shader = post_processing.get_node("BlackoutBlur").material
	ui = main.get_node("UI")
	inventory = ui.inventory_menu
	journal_log = ui.log_entries_menu
	found_notes = ui.found_notes_menu
	cursor = main.get_node("Cursor")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)	
	
	await player.ready
	
	camera_controller = player.camera_controller
	camera = camera_controller.camera


func lock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cursor.visible = false
	mouse_locked = true


func unlock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor.visible = true
	mouse_locked = false
