extends Node

signal started
signal stopped
signal timeout
signal time_scale_changed(scale: float)

const STARTING_TIME_LEFT := 60.0
const MAX_TIME_LEFT_ALLOW_DRINK := 600.1
const MAX_WAIT_TIME := 900.0

var time_scale := 1.0 : set = set_time_scale
var wait_time :=  STARTING_TIME_LEFT : set = set_wait_time
var time_left :=  STARTING_TIME_LEFT : set = _set_time_left
var paused := true : set = set_paused

var _tweening_time := false

@onready var saver_loader: SaverLoader = preload("res://source/actors/tools/saver_loader.tscn").instantiate()


func _ready() -> void:
	add_child(saver_loader)
	saver_loader.unique_id = saver_loader.get_path() as String


func _process(delta):
	if not paused and not _tweening_time and not is_equal_approx(time_left, 0.0):
		time_left -= delta * time_scale
		
	Global.main.debug_affliction_time_left.text = "Time Left: " + formatted_time_left()


func set_time_scale(time_scale_: float):
	time_scale = time_scale_
	time_scale_changed.emit(time_scale)


func set_wait_time(wait_time_: float):
	wait_time = clamp(wait_time_, 0.0,  MAX_TIME_LEFT_ALLOW_DRINK)
	time_left = wait_time
	if wait_time > 0.0001:
		start()


func _set_time_left(time_left_: float):
	time_left = clamp(time_left_, 0.0, wait_time)
	if is_zero_approx(time_left):
		timeout.emit()
		stopped.emit()


func set_paused(paused_: bool):
	if paused == paused_:
		return
		
	paused = paused_
	if paused:
		stopped.emit()
	else:
		started.emit()


func start(at_time: float = wait_time):
	if not paused and not _tweening_time:
		time_left = at_time
		started.emit()


func pause():
	paused = true


func unpause():
	paused = false


func formatted_time_left():
	var mins := int(floor(time_left / 60.0))
	var secs := int(floor(time_left)) % 60
	return "%d:%02d" % [mins, secs]


func add_time_secs(time_secs: float, over_duration: float = 0.0):
	if is_zero_approx(over_duration):
		time_left += time_secs
	else:
		_set_time_over_time(time_left + time_secs, over_duration)


func add_time_mins(time_mins: float, over_duration: float = 0.0):
	if is_zero_approx(over_duration):
		time_left += time_mins * 60.0
	else:
		_set_time_over_time(time_left + time_mins * 60.0, over_duration)


func set_time_secs(time_secs: float, over_duration: float = 0.0):
	if is_zero_approx(over_duration):
		time_left = time_secs
	else:
		_set_time_over_time(time_secs, over_duration)


func set_time_mins(time_mins: float, over_duration: float = 0.0):
	if is_zero_approx(over_duration):
		time_left = time_mins * 60.0
	else:
		_set_time_over_time(time_mins * 60.0, over_duration)


func _set_time_over_time(time_secs: float, over_duration: float):
	_tweening_time = true
	var tween: Tween = create_tween()
	tween.tween_method(_set_time_left, time_left, time_secs, over_duration)
	
	await tween.finished
	_tweening_time = false


func get_save_properties():
	return [
		"time_scale",
		"wait_time",
		"time_left",
		"paused",
	] as Array[String]
