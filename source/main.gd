extends Node

# Distances at which max/min effect intensity is achieved
const EFFECT_MIN_DIST = 10
const EFFECT_MAX_DIST = 30

@export var anim_chrom_abb_offset: float
@export var anim_vignette_softness: float
@export var debug_no_title_screen: bool = false

var player_dist_to_creature: float

var do_prologue = false
var enable_heartbeat = false

var player_preload = preload("res://source/actors/player/player.tscn")

var load_screen_res: Resource = preload("res://source/assets/ui/load_screen.tscn")
var death_screen_res: Resource = preload("res://source/assets/ui/death_screen.tscn")
var title_screen_res: Resource = preload("res://source/assets/ui/title_screen.tscn")
var world_res: Resource = preload("res://source/world.tscn")
var title_screen_room_res: Resource = preload("res://source/actors/rooms/title_screen_room.tscn")

var drip_ambience: Resource = load("res://source/assets/sounds/ambience/general/drip_ambience.ogg")
var drip_ambience_upside_down: Resource = load("res://source/assets/sounds/ambience/general/drip_ambience_upside_down.ogg")

var title_screen_room: Node3D
var title_screen: Control
var world: Node3D

var obunga

@onready var drone_player = $drone_player
@onready var drip_player = $drip_player
@onready var play_game_sound_player = $play_game_sound_player
@onready var retro_shader = $post_processing/retro_shader
@onready var chromatic_abberation = $post_processing/chromatic_abberation
@onready var vignette = $post_processing/vignette
@onready var zoom = $post_processing/zoom
@onready var blackout_blur = $post_processing/blackout_blur
@onready var effects_player = $effects_player
@onready var heartbeat_anim = effects_player.get_animation("heartbeat")
@onready var heartbeat_player = $heartbeat_player
@onready var ui = $ui
@onready var nav_update_timer: Timer = Timer.new()
@onready var debug_affliction_time_left = $timer_label

@export_range(0.0, 2.0) var light_energy_multiplier: float = 1.0

signal world_loaded
signal world_ready


func _ready() -> void:
	AudioServer.get_bus_effect(0, 0).volume_db = linear_to_db(0.25) - 5.0
	if debug_no_title_screen:
		load_world_and_player()
	else:
		load_title_screen()
		
	if !do_prologue:
		$prologue.queue_free()
	else:
		Global.player.in_menu = true


func _process(_delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("debug2"):
		Global.player.fear_player.play()
		Global.player.fear_pulse_player.play()
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(Global.player.fear_player, "volume_db", 0.0, 1.5).from(-50.0)
		tween.parallel().tween_property(Global.player.fear_pulse_player, "volume_db", 10.0, 1.5).from(-50.0)
		tween.parallel().tween_property(AudioServer.get_bus_effect(1, 0), "cutoff_hz", 1000, 1.5).from(20500)
		tween.parallel().tween_property(Global.zoom_shader, "shader_parameter/intensity", 15.0, 1.5)
		tween.parallel().tween_property(Global.vignette_shader, "shader_parameter/softness", 0.75, 1.5)
	
	if Input.is_action_just_pressed("debug"):
		if Global.mouse_locked:
			Global.unlock_mouse()
		else:
			Global.lock_mouse()
	
	#if Input.is_action_just_pressed("debug2"):
	#	get_viewport().get_texture().get_image().save_png("C:\\Users\\Aaron Hall\\Desktop\\image.png")
			
	#if Input.is_action_just_pressed("tilde"):
		#if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		#else:
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_action_just_pressed("pause"):
		if ui.menus.open_menus.size() > 0 and ui.menus.back != title_screen:
			ui.remove_menu()
		else:
			ui.display_menu(ui.pause_menu)


func load_title_screen():
	title_screen = title_screen_res.instantiate()
	title_screen_room = title_screen_room_res.instantiate()
	ui.menus.add_menu(title_screen)
	add_child(title_screen_room)
	Global.unlock_mouse()
	title_screen_room.get_node("camera").current = true


func load_world_and_player():
	var tween1: Tween
	if not debug_no_title_screen:
		Global.player.scripted_event = true
		
		tween1 = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween1.tween_property(Global.blackout_blur_shader, "shader_parameter/blurAmount", 1.0, 3.0).from(2.0)
		tween1.parallel().tween_property(Global.blackout_blur_shader, "shader_parameter/colorScale", 0.3, 3.0).from(0.0)
		
		await get_tree().process_frame
	
	if title_screen_room:
		title_screen_room.queue_free()
	if title_screen:
		ui.remove_menu()
	
	world = world_res.instantiate()
	add_child(world)
	emit_signal("world_ready")
	
	if not nav_update_timer.is_inside_tree():
		add_child(nav_update_timer)
	nav_update_timer.wait_time = 0.1
	for enemy in get_tree().get_nodes_in_group("enemies"):
		nav_update_timer.connect("timeout", enemy.update_target_position)
	nav_update_timer.start()
	world.get_node("nav_region").bake_navigation_mesh()
	
	Global.lock_mouse()
	Global.player.position = world.get_node("player_spawn_point").global_position
	if not Global.player.is_inside_tree():
		add_child(Global.player)
	Global.player.cam.rotation = Vector3.ZERO
	Global.player.cam.target_rotation = Vector3.ZERO
	
	# Make sure the player is rendered before post-processing so torch is affected
	# by post-processing
	move_child(Global.player, 0)
	
	drone_player.play()
	
	if not debug_no_title_screen:
		await tween1.finished
		await get_tree().create_timer(3.0, false).timeout
		
		var tween2: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(Global.blackout_blur_shader, "shader_parameter/blurAmount", 0.0, 4.0)
		tween2.parallel().tween_property(Global.blackout_blur_shader, "shader_parameter/colorScale", 1.0, 3.0)
		
		await tween2.finished
		
		Global.player.scripted_event = false


func _report_load_progress():
	var progress: Array = []
	while true:
		
		# For some reason calling load_threaded_get_status every frame causes random crash
		# with no error
		await get_tree().create_timer(0.1, false).timeout
		
		var status: = ResourceLoader.load_threaded_get_status("res://source/world.tscn", progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			world = ResourceLoader.load_threaded_get("res://source/world.tscn").instantiate()
			emit_signal("world_loaded")
			return
		else:
			push_error("Error loading world")


func _calculate_effects_scale():
	var clamped_dist = clamp(player_dist_to_creature, EFFECT_MIN_DIST, EFFECT_MAX_DIST)
	var scale = (clamped_dist - EFFECT_MIN_DIST) / (EFFECT_MAX_DIST - EFFECT_MIN_DIST)
	scale = 1 - scale
	return scale * scale


func fear_effect_timed(duration: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(zoom.material, "shader_parameter/intensity", 15.0, 1.0).from(0.0)
	tween.parallel().tween_property(vignette.material, "shader_parameter/softness", 1.0, 1.0).from(3.0)
	
	await get_tree().create_timer(duration, false).timeout
	
	var tween2 = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween2.parallel().tween_property(zoom.material, "shader_parameter/intensity", 0.0, 3.0).from(15.0)
	tween2.parallel().tween_property(vignette.material, "shader_parameter/softness", 3.0, 3.0).from(1.0)


func set_upside_down_sound(on: bool):
	var time: float = drip_player.get_playback_position()
	drip_player.stop()
	if on:
		drip_player.stream = drip_ambience_upside_down
	else:
		drip_player.stream = drip_ambience
	drip_player.play(time)


func _do_heartbeat(effects_scale):
	var chrom_abb_offset = anim_chrom_abb_offset * effects_scale
	var vignette_softness = lerp(1.0, anim_vignette_softness, effects_scale)
	chromatic_abberation.material.set_shader_parameter("offset", chrom_abb_offset)
	vignette.material.set_shader_parameter("softness", vignette_softness)
	heartbeat_player.volume_db = lerp(-17.5, 0.0, effects_scale)
	drone_player.volume_db = lerp(-5, -30, effects_scale * effects_scale)
