extends Node

# HC = Hard Cap
const ZOOM_INTENSITY_HC: float = 15.0
const VIGNETTE_SOFTNESS_HC: float = 0.75
const PLAYER_SPEED_MULT_HC: float = 0.5
const CAM_SENS_MULT_HC: float = 0.25
const CAM_BOB_FREQ_MULT_HC: float = 0.5

# SC = Soft Cap
const ZOOM_INTENSITY_SC: float = 8.0
const VIGNETTE_SOFTNESS_SC: float = 0.8
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
var vignette_softness: float
var player_speed_mult: float
var cam_sens_mult: float
var cam_bob_freq_mult: float
var cam_soft_movement_weight: float


func _process(_delta):
	if not being_tweened and not override_effect_scale and first_dose_taken and Global.player.affliction_timer:
		effect_scale = 1.0 - clamp(Global.player.affliction_timer.time_left / 60.0, 0.0, 1.0)
		zoom_intensity = lerp(ZOOM_INTENSITY_DEF, ZOOM_INTENSITY_SC, effect_scale)
		vignette_softness = lerp(VIGNETTE_SOFTNESS_DEF, VIGNETTE_SOFTNESS_SC, effect_scale)
		player_speed_mult = lerp(1.0, PLAYER_SPEED_MULT_SC, effect_scale)
		cam_sens_mult = lerp(1.0, CAM_BOB_FREQ_MULT_SC, effect_scale)
		cam_bob_freq_mult = lerp(1.0, cam_bob_freq_mult, effect_scale)
		cam_soft_movement_weight = lerp(Global.player.cam.SOFT_MOVEMENT_MIN_WEIGHT, Global.player.cam.SOFT_MOVEMENT_MAX_WEIGHT, effect_scale)
		
		Global.zoom_shader.set_shader_parameter("intensity", zoom_intensity)
		Global.vignette_shader.set_shader_parameter("softness", vignette_softness)


func set_to_beyond_max_effect(time: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", ZOOM_INTENSITY_HC, time)
	tween.parallel().tween_property(Global.vignette_shader, "shader_parameter/softness", VIGNETTE_SOFTNESS_HC, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", PLAYER_SPEED_MULT_HC, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "sensitivity_multiplier", CAM_SENS_MULT_HC, time / 2.0)
	tween.parallel().tween_property(Global.player.bob_controller, "bob_speed_multiplier", CAM_BOB_FREQ_MULT_HC, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "soft_movement_weight", 0.01, time / 2.0)
	tween.tween_callback(set.bind("being_tweened", false))


func set_to_max_effect(time: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", ZOOM_INTENSITY_SC, time)
	tween.parallel().tween_property(Global.vignette_shader, "shader_parameter/softness", VIGNETTE_SOFTNESS_SC, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", PLAYER_SPEED_MULT_SC, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "sensitivity_multiplier", CAM_SENS_MULT_SC, time / 2.0)
	tween.parallel().tween_property(Global.player.bob_controller, "bob_speed_multiplier", CAM_BOB_FREQ_MULT_SC, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "soft_movement_weight", 0.025, time / 2.0)
	tween.tween_callback(set.bind("being_tweened", false))


func set_to_min_effect(time: float):
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", ZOOM_INTENSITY_DEF, time)
	tween.parallel().tween_property(Global.vignette_shader, "shader_parameter/softness", VIGNETTE_SOFTNESS_DEF, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "sensitivity_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.bob_controller, "bob_speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "soft_movement_weight", 1.0, time / 2.0)
	tween.tween_callback(set.bind("being_tweened", false))


func release_override(time: float):
	effect_scale = 1.0 - clamp(((Global.player.affliction_timer.time_left - time) / 60.0), 0.0, 1.0)
	zoom_intensity = lerp(ZOOM_INTENSITY_DEF, ZOOM_INTENSITY_SC, effect_scale)
	vignette_softness = lerp(VIGNETTE_SOFTNESS_DEF, VIGNETTE_SOFTNESS_SC, effect_scale)
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	being_tweened = true
	tween.tween_property(Global.zoom_shader, "shader_parameter/intensity", zoom_intensity, time)
	tween.parallel().tween_property(Global.vignette_shader, "shader_parameter/softness", vignette_softness, time)
	tween.parallel().tween_property(Global.player, "speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "sensitivity_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.bob_controller, "bob_speed_multiplier", 1.0, time / 2.0)
	tween.parallel().tween_property(Global.player.cam, "soft_movement_weight", 1.0, time / 2.0)
	tween.tween_callback(func (): being_tweened = false; override_effect_scale = false)
