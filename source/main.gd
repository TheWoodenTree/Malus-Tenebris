extends Node

# Distances at which max/min effect intensity is achieved
const EFFECT_MIN_DIST = 10
const EFFECT_MAX_DIST = 30

@export var anim_chrom_abb_offset: float
@export var anim_vignette_softness: float

var player_dist_to_creature: float

var do_prologue = false
var enable_heartbeat = false

var player_preload = preload("res://source/actors/player/player.tscn")

var load_screen_res: Resource = load("res://source/assets/ui/load_screen.tscn")
var death_screen_res: Resource = load("res://source/assets/ui/death_screen.tscn")

var drip_ambience: Resource = load("res://source/assets/sounds/ambience/general/drip_ambience.ogg")
var drip_ambience_upside_down: Resource = load("res://source/assets/sounds/ambience/general/drip_ambience_upside_down.ogg")

var world: Node3D

var obunga

@onready var drone_player = $drone_player
@onready var drip_player = $drip_player
@onready var retro_shader = $post_processing/retro_shader
@onready var chromatic_abberation = $post_processing/chromatic_abberation
@onready var vignette = $post_processing/vignette
@onready var zoom = $post_processing/zoom
@onready var effects_player = $effects_player
@onready var heartbeat_anim = effects_player.get_animation("heartbeat")
@onready var heartbeat_player = $heartbeat_player
@onready var ui = $ui
@onready var nav_update_timer: Timer = Timer.new()

@export_range(0.0, 2.0) var light_energy_multiplier: float = 1.0

signal world_loaded
signal world_ready


func _ready() -> void:
	var load_screen: Control = load_screen_res.instantiate()
	call_deferred("add_child", load_screen)
	
	var err: Error = ResourceLoader.load_threaded_request("res://source/world.tscn", "", true)
	if err != 0:
		push_error("Error requesting threaded load of world, error code " + str(err))
	
	# Report load progress on separate thread so loading screen doesn't have to be static
	var load_progress_thread = Thread.new()
	load_progress_thread.start(_report_load_progress)
	
	await world_loaded
	
	call_deferred("add_child", world)

	await world.ready
	
	#obunga = world.get_node("nav_region/obunga")
	emit_signal("world_ready")
	load_screen.queue_free()
	load_progress_thread.wait_to_finish()
	
	Global.lock_mouse()
	Global.player.position = world.get_node("player_spawn_point").global_position
	add_child(Global.player)
	
	# Make sure the player is rendered before post-processing so torch is affected
	# by post-processing
	move_child(Global.player, 0)
	
	if !do_prologue:
		$prologue.queue_free()
	else:
		Global.player.in_menu = true
	
	drone_player.play()
	drip_player.play()
	
	add_child(nav_update_timer)
	nav_update_timer.wait_time = 0.1
	for enemy in get_tree().get_nodes_in_group("enemies"):
		nav_update_timer.connect("timeout", enemy.update_target_position)
	nav_update_timer.start()
	
	world.get_node("nav_region").bake_navigation_mesh()


func _process(_delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())
	if Input.is_action_just_pressed("debug2"):
		Global.player.fear_player.play();
		var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(Global.player.fear_player, "volume_db", 0.0, 1.5).from(-50.0)
		tween.parallel().tween_property(zoom.material, "shader_parameter/intensity", 15.0, 1.5).from(0.0)
		tween.parallel().tween_property(vignette.material, "shader_parameter/softness", 0.75, 1.5).from(1.5)
		tween.parallel().tween_property(AudioServer.get_bus_effect(1, 0), "cutoff_hz", 1000, 1.5).from(20500)
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Global.mouse_locked:
			Global.unlock_mouse()
		else:
			Global.lock_mouse()
	
	#if Input.is_action_just_pressed("debug2"):
	#	get_viewport().get_texture().get_image().save_png("C:\\Users\\Aaron Hall\\Desktop\\image.png")
			
	if Input.is_action_just_pressed("tilde"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


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
