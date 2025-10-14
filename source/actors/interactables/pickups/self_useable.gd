@abstract
class_name SelfUseable
extends Pickup

@export var use_sound: AudioStream

var is_useable := true
var was_used := false
var was_held_before := false


@abstract func use()
