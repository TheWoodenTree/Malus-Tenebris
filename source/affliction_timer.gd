extends Timer

signal started
signal stopped

const MAX_AFFLICTION_TIMER_ALLOW_DRINK := 600.1
const MAX_AFFLICTION_TIMER_VALUE := 900.0


func _ready() -> void:
	timeout.connect(func(): stopped.emit()) # For consistency
	one_shot = true


func _process(_delta):
	Global.main.debug_affliction_time_left.text = "Time Left: " + formatted_time_left()


func _set(property: StringName, value: Variant):
	if property == 'wait_time':
		wait_time = clamp(value, 0.0, MAX_AFFLICTION_TIMER_VALUE)
		if wait_time > 0.0001:
			start()
			if not paused:
				started.emit()
	
	if property == 'paused':
		paused = value
		if paused:
			stopped.emit()
		else:
			started.emit()


func formatted_time_left():
	var mins := int(floor(time_left / 60.0))
	var secs := int(floor(time_left)) % 60
	return "%d:%02d" % [mins, secs]


func add_time_secs(time_secs: float):
	self.wait_time = time_left + time_secs


func add_time_mins(time_mins: float):
	self.wait_time = time_left + time_mins * 60.0


func set_time_secs(time_secs: float):
	self.wait_time = time_secs


func set_time_mins(time_mins: float):
	self.wait_time = time_mins * 60.0
