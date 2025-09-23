extends Light3D

const FAST_FLICKER_VARIATION := 0.2
const SLOW_FLICKER_VARIATION := 0.5
const FLARE_VARIATION := 1.0

@onready var default_color: Color = light_color

var timer = Timer.new()

var fast_flicker_energy := 0.0
var fast_flicker_color := Color.BLACK
var slow_flicker_energy := 0.0
var slow_flicker_color := Color.BLACK
var flare_energy := 0.0
var flare_color := Color.BLACK

var default_range: float
var default_energy: float


func _ready() -> void:
	timer.one_shot = true
	add_child(timer)


func _process(_delta: float) -> void:
	if visible:
		light_energy = default_energy + fast_flicker_energy + slow_flicker_energy + flare_energy
		light_color = default_color + fast_flicker_color + slow_flicker_color + flare_color


func flicker():
	_fast_flicker()
	_slow_flicker()
	_flare()


func _fast_flicker():
	var flicker_duration = randf_range(0.05, 0.1)
	var intensity = pow(randf(), 2.0)
	var flicker_variation = lerp(-FAST_FLICKER_VARIATION, FAST_FLICKER_VARIATION, intensity)
	#var color_flicker = lerp(Color.BLACK, Color(0.1, 0.075, -0.175, 1.0), intensity)
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "fast_flicker_energy", flicker_variation, flicker_duration).from_current()
	#flicker_tween.parallel().tween_property(self, "fast_flicker_color", color_flicker, flicker_duration).from_current()
	flicker_tween.tween_callback(_fast_flicker)


func _slow_flicker():
	var flicker_duration = randf_range(0.5, 1.0)
	var intensity = pow(randf(), 2.0)
	var flicker_variation = lerp(-SLOW_FLICKER_VARIATION, SLOW_FLICKER_VARIATION, intensity)
	#var color_flicker = lerp(Color.BLACK, Color(0.1, 0.075, -0.175, 1.0), intensity)
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "slow_flicker_energy", flicker_variation, flicker_duration).from_current()
	#flicker_tween.parallel().tween_property(self, "slow_flicker_color", color_flicker, flicker_duration).from_current()
	flicker_tween.tween_callback(_slow_flicker)


func _flare():
	var flicker_duration = randf_range(0.1, 0.2)
	var flicker_variation = lerp(0.5, 1.2, randf_range(0.0, 1.0))
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "flare_energy", flicker_variation, flicker_duration).from_current()
	flicker_tween.tween_interval(randf_range(0.05, 0.15))
	flicker_tween.tween_property(self, "flare_energy", 0.0, 0.15)
	flicker_tween.tween_interval(randf_range(2.0, 4.0))
	flicker_tween.tween_callback(_flare)
	
