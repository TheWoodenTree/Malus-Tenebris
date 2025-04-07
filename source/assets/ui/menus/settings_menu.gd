extends Menu

@onready var volume_slider: HSlider = $Cont/VBoxCont/VBoxCont/HBoxCont/VBoxCont/VolumeSlider
@onready var slider_click_player: AudioStreamPlayer = $Cont/VBoxCont/VBoxCont/HBoxCont/VBoxCont/SliderClickPlayer
@onready var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	timer.wait_time = 0.1
	add_child(timer)


func _on_volume_slider_value_changed(value):
	AudioServer.get_bus_effect(0, 0).volume_db = linear_to_db(value)
	if timer.is_stopped():
		slider_click_player.play()
		timer.start()
