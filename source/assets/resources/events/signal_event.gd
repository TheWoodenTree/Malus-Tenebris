class_name SignalEvent
extends Event

@export var global_signal_name: String


func _execute() -> void:
	GlobalSignals.emit_signal(global_signal_name)
