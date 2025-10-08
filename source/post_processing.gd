class_name PostProcessing
extends Control

@export var heartbeat_curve: Curve

const PAIN_VIGNETTE_FULL_HP_MULTIPLIER = 0.7
const PAIN_VIGNETTE_NEAR_FULL_HP_MULTIPLIER = 0.42
const PAIN_VIGNETTE_NEAR_DEATH_MUTLIPLIER = 0.15

@onready var pain_vignette: ColorRect = $PainVignette

var pain_vignette_tween: Tween
var time_since_start := 0.0


func _process(delta: float) -> void:
	if Global.player.health < Player.MAX_HP / 3.0:
		time_since_start += delta
		var heartbeat_time: float = wrapf(time_since_start, 0.0, 2.0)
		var heartbeat_amount: float = heartbeat_curve.sample(heartbeat_time) * 0.05
		pain_vignette.material.set_shader_parameter("multiplierOffset", -heartbeat_amount)


func blend_pain_vignette_multiplier(multiplier: float, duration := 0.1):
	pain_vignette_tween = get_tree().create_tween()
	pain_vignette_tween.tween_property(pain_vignette.material, "shader_parameter/multiplier", multiplier, duration)
