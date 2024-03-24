extends Timer


func _process(_delta):
	Global.main.debug_affliction_time_left.text = "Time Left: " + formatted_time_left()


func formatted_time_left():
	var mins: int = int(floor(time_left / 60.0))
	var secs: int = int(floor(time_left)) % 60
	return "%d:%02d" % [mins, secs]


func add_time_secs(time_secs: float):
	wait_time = time_left + time_secs
	if wait_time > 0.0:
		start()


func add_time_mins(time_mins: float):
	wait_time = time_left + time_mins * 60.0
	if wait_time > 0.0:
		start()


func set_time_secs(time_secs: float):
	wait_time = time_secs
	if wait_time > 0.0:
		start()


func set_time_mins(time_mins: float):
	wait_time = time_mins * 60.0
	if wait_time > 0.0:
		start()
