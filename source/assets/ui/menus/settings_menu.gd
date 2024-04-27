extends Menu


func _on_volume_slider_value_changed(value):
	AudioServer.get_bus_effect(0, 0).volume_db = linear_to_db(value) - 5.0
