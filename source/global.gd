extends Node

####################
# GLOBAL VARIABLES #
####################
var world: Node3D
var world_environment: WorldEnvironment
var post_processing: Control
var retro_shader: Material
var chromatic_abberation_shader: Material
var vignette_shader: Material
var zoom_shader: Material
var ui: Control
var inventory: Control
var cursor: Node2D

var mouse_sens: float = 0.4
var mouse_locked: bool

var monster: CharacterBody3D

@onready var main: Node = get_tree().root.get_node("main")
@onready var player: CharacterBody3D = load("res://source/actors/player/player.tscn").instantiate()


#Init Globals
func _ready() -> void:
	main.connect("world_ready", func(): world = main.get_node("world"); monster = world.get_node("monster"))
	world_environment = main.get_node("world_environment")
	post_processing = main.get_node("post_processing")
	if post_processing != null:
		retro_shader = post_processing.get_node("retro_shader").material
		chromatic_abberation_shader = post_processing.get_node("chromatic_abberation").material
		vignette_shader = post_processing.get_node("vignette").material
		zoom_shader = post_processing.get_node("zoom").material
	ui = main.get_node("ui")
	inventory = ui.inventory_menu
	cursor = main.get_node("cursor")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func lock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cursor.visible = false
	mouse_locked = true


func unlock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor.visible = true
	mouse_locked = false
