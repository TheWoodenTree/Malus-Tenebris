extends OmniLight3D

const FLICKER_INTENSITY = 1.2

var timer = Timer.new()

var default_range
var default_energy


func _ready() -> void:
	#omni_range = default_range
	#light_energy = default_energy
	
	timer.one_shot = true
	add_child(timer)
	_load_sounds()
	#flicker()


func _load_sounds():
	pass


func flicker():
	var flicker_low = default_energy / FLICKER_INTENSITY
	var flicker_high = default_energy * FLICKER_INTENSITY
	var flicker_duration = randf_range(0.1, 0.2)
	var flicker_intensity = randf_range(0, 1)
	var energy_flicker = lerp(flicker_low, flicker_high, flicker_intensity) * Global.main.light_energy_multiplier
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "light_energy", \
		energy_flicker, flicker_duration).from_current()
	flicker_tween.tween_callback(flicker)
