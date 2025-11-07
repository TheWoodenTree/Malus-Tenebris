extends Node

# HC = Hard Cap
const ZOOM_INTENSITY_HC: float = 20.0
const PLAYER_SPEED_MULT_HC: float = 0.5
const CAM_SENS_MULT_HC: float = 0.25
const CAM_BOB_FREQ_MULT_HC: float = 0.5

# SC = Soft Cap
const ZOOM_INTENSITY_SC: float = 15.0
const PLAYER_SPEED_MULT_SC: float = 0.85
const CAM_SENS_MULT_SC: float = 0.75
const CAM_BOB_FREQ_MULT_SC: float = 0.85

const ZOOM_INTENSITY_DEF: float = 0.0
const VIGNETTE_SOFTNESS_DEF: float = 2.0

var being_tweened: bool = false
var override_effect_scale: bool = false
var first_dose_taken: bool = false

var effect_scale: float
var zoom_intensity: float
var player_speed_mult: float
var cam_sens_mult: float
var cam_bob_freq_mult: float
var cam_soft_movement_weight: float

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String


func _process(_delta):
	if not being_tweened and not override_effect_scale and first_dose_taken and AfflictionTimer:
		effect_scale = 1.0 - clamp(AfflictionTimer.time_left / 30.0, 0.0, 1.0)
		zoom_intensity = lerp(ZOOM_INTENSITY_DEF, ZOOM_INTENSITY_SC, effect_scale)
		player_speed_mult = lerp(1.0, PLAYER_SPEED_MULT_SC, effect_scale)
		cam_sens_mult = lerp(1.0, CAM_BOB_FREQ_MULT_SC, effect_scale)
		cam_bob_freq_mult = lerp(1.0, cam_bob_freq_mult, effect_scale)
		cam_soft_movement_weight = lerp(Global.camera_controller.SOFT_MOVEMENT_MIN_WEIGHT, Global.camera_controller.SOFT_MOVEMENT_MAX_WEIGHT, effect_scale)
		
		Global.zoom_shader.set_shader_parameter("intensity", zoom_intensity)


func set_to_beyond_max_effect(time: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", ZOOM_INTENSITY_HC, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", PLAYER_SPEED_MULT_HC, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "sensitivity_multiplier", CAM_SENS_MULT_HC, time / 2.0)
	tween.parallel().tween_property(Global.player.camera_controller, "bob_speed_multiplier", CAM_BOB_FREQ_MULT_HC, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "soft_movement_weight", 0.01, time / 2.0)
	tween.tween_callback(set.bind("being_tweened", false))


func set_to_max_effect(time: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", ZOOM_INTENSITY_SC, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", PLAYER_SPEED_MULT_SC, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "sensitivity_multiplier", CAM_SENS_MULT_SC, time / 2.0)
	tween.parallel().tween_property(Global.player.camera_controller, "bob_speed_multiplier", CAM_BOB_FREQ_MULT_SC, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "soft_movement_weight", 0.025, time / 2.0)
	tween.tween_callback(set.bind("being_tweened", false))


func set_to_min_effect(time: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", ZOOM_INTENSITY_DEF, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "sensitivity_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.camera, "bob_speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "soft_movement_weight", 1.0, time / 2.0)
	tween.tween_callback(set.bind("being_tweened", false))


func release_override(time: float):
	effect_scale = 1.0 - clamp(((AfflictionTimer.time_left - time) / 60.0), 0.0, 1.0)
	zoom_intensity = lerp(ZOOM_INTENSITY_DEF, ZOOM_INTENSITY_SC, effect_scale)
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", zoom_intensity, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "sensitivity_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.camera_controller, "bob_speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.camera_controller, "soft_movement_weight", 1.0, time / 2.0)
	tween.tween_callback(func (): being_tweened = false; override_effect_scale = false)



func get_save_properties():
	return ["first_dose_taken"] as Array[String]
