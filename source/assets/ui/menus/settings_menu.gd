extends Menu

@onready var volume_slider: HSlider = $cont/v_box_cont/v_box_cont/h_box_cont/v_box_cont/volume_slider
@onready var slider_click_player: AudioStreamPlayer = $cont/v_box_cont/v_box_cont/h_box_cont/v_box_cont/slider_click_player
@onready var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	timer.wait_time = 0.1
	add_child(timer)


func _on_volume_slider_value_changed(value):
	AudioServer.get_bus_effect(0, 0).volume_db = linear_to_db(value) - 10.0
	if timer.is_stopped():
		slider_click_player.play()
		timer.start()
