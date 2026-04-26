class_name FireLight
extends Light3D

const FAST_FLICKER_VARIATION := 0.2
const SLOW_FLICKER_VARIATION := 0.5
const FLARE_VARIATION := 1.0

var timer = Timer.new()

var fast_flicker_energy := 0.0
var slow_flicker_energy := 0.0
var flare_energy := 0.0

var default_energy: float

var enable_flicker := false
var do_visible_notifier_update := true

@onready var visible_notifier: VisibleOnScreenNotifier3D = $VisibleNotifier if has_node('VisibleNotifier') else null


func _ready() -> void:
	timer.one_shot = true
	add_child(timer)


func _process(_delta: float) -> void:
	if visible and enable_flicker:
		light_energy = default_energy + fast_flicker_energy + slow_flicker_energy + flare_energy


func _set(attribute: StringName, value: Variant):
	if attribute == 'omni_range':
		if visible_notifier and do_visible_notifier_update:
			_update_visible_notifier_aabb(value)
		return true
	return false


func flicker():
	_fast_flicker()
	_slow_flicker()
	_flare()


func _fast_flicker():
	if not enable_flicker and visible_notifier and do_visible_notifier_update:
		await visible_notifier.screen_entered
	var flicker_duration = randf_range(0.05, 0.1)
	var intensity = pow(randf(), 2.0)
	var flicker_variation = lerp(-FAST_FLICKER_VARIATION, FAST_FLICKER_VARIATION, intensity)
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "fast_flicker_energy", flicker_variation, flicker_duration).from_current()
	flicker_tween.tween_callback(_fast_flicker)


func _slow_flicker():
	if not enable_flicker and visible_notifier and do_visible_notifier_update:
		await visible_notifier.screen_entered
	var flicker_duration = randf_range(0.5, 1.0)
	var intensity = pow(randf(), 2.0)
	var flicker_variation = lerp(-SLOW_FLICKER_VARIATION, SLOW_FLICKER_VARIATION, intensity)
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "slow_flicker_energy", flicker_variation, flicker_duration).from_current()
	flicker_tween.tween_callback(_slow_flicker)


func _flare():
	if not enable_flicker and visible_notifier and do_visible_notifier_update:
		await visible_notifier.screen_entered
	var flicker_duration = randf_range(0.1, 0.2)
	var flicker_variation = lerp(0.5, 1.2, randf_range(0.0, 1.0))
	var flicker_tween = get_tree().create_tween()
	flicker_tween.tween_property(self, "flare_energy", flicker_variation, flicker_duration).from_current()
	flicker_tween.tween_interval(randf_range(0.05, 0.15))
	flicker_tween.tween_property(self, "flare_energy", 0.0, 0.15)
	flicker_tween.tween_interval(randf_range(2.0, 4.0))
	flicker_tween.tween_callback(_flare)


func _update_visible_notifier_aabb(light_range: float):
	var aabb_position := Vector3(-light_range, -light_range, -light_range)
	var aabb_size := 2.0 * Vector3(light_range, light_range, light_range)
	visible_notifier.aabb = AABB(aabb_position, aabb_size)
	
	visible_notifier.screen_entered.connect(set_enable_flicker.bind(true))
	visible_notifier.screen_exited.connect(set_enable_flicker.bind(false))


func set_enable_flicker(enable_flicker_: bool):
	enable_flicker = enable_flicker_
	shadow_enabled = enable_flicker
	set_process(enable_flicker)
