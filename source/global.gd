extends Node

const PLAYER_SCENE_PATH = "res://source/actors/characters/player/player.tscn"

######################
## GLOBAL VARIABLES ##
######################
var main: Main
var world: Node3D
var world_environment: WorldEnvironment
var nav_region: NavigationRegion3D
var post_processing: PostProcessing
var retro_shader: Material
var chromatic_abberation_shader: Material
var vignette_shader: Material
var zoom_shader: Material
var blackout_blur_shader: Material
var ui: UI
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

@onready var player: Player = load(PLAYER_SCENE_PATH).instantiate()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func lock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cursor.visible = false
	mouse_locked = true


func unlock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor.visible = true
	mouse_locked = false


func reset_game():
	ui.process_mode = Node.PROCESS_MODE_DISABLED
	var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(Blackout.color_rect.material, "shader_parameter/alpha", 1.0, 1.5)
	
	await tween.finished
	get_tree().reload_current_scene()
	player = load(PLAYER_SCENE_PATH).instantiate()
	
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(Blackout.color_rect.material, "shader_parameter/alpha", 0.0, 1.5)
	
