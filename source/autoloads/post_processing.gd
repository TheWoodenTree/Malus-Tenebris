class_name PostProcessing
extends Control

@export var heartbeat_curve: Curve

const PAIN_VIGNETTE_FULL_HP_MULTIPLIER = 0.7
const PAIN_VIGNETTE_NEAR_DEATH_MUTLIPLIER = 0.3

const HEAL_COLOR_OVERLAY_MAX_ALPHA = 0.078

@onready var blackout_blur: ColorRect = $BlackoutBlur
@onready var zoom: ColorRect = $Zoom
@onready var pain_vignette: ColorRect = $PainVignette
@onready var vignette: ColorRect = $Vignette
@onready var retro_shader: ColorRect = $RetroShader
@onready var heal_color_overlay: ColorRect = $HealColorOverlay


var pain_vignette_tween: Tween
var heal_color_overlay_tween: Tween
var time_since_start := 0.0


func _ready() -> void:
	Global.retro_shader = retro_shader.material
	Global.zoom_shader = zoom.material
	Global.vignette_shader = vignette.material
	Global.blackout_blur_shader = blackout_blur.material


func _process(delta: float) -> void:
	if Global.player.health < Player.MAX_HP / 3.0:
		time_since_start += delta
		var heartbeat_time: float = wrapf(time_since_start, 0.0, 2.0)
		var heartbeat_amount: float = heartbeat_curve.sample(heartbeat_time) * 0.05
		pain_vignette.material.set_shader_parameter("multiplierOffset", -heartbeat_amount)


func blend_pain_vignette_multiplier(multiplier: float, duration := 0.1):
	pain_vignette_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	pain_vignette_tween.tween_property(pain_vignette.material, "shader_parameter/multiplier", multiplier, duration)


func flash_heal_color_overlay():
	heal_color_overlay_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	heal_color_overlay_tween.tween_property(heal_color_overlay, "color:a", HEAL_COLOR_OVERLAY_MAX_ALPHA, 0.3)
	heal_color_overlay_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	heal_color_overlay_tween.tween_property(heal_color_overlay, "color:a", 0.0, 1.5)


func get_save_properties():
	return [
		"pain_vignette:material:shader_parameter/multiplier",
	] as Array[String]
