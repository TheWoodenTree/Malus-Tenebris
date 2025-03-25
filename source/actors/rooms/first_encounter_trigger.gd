extends Area3D

var triggered: bool = false
var can_trigger: bool = false

@onready var sound_player = $SoundPlayer
@onready var sound_trigger_area = %SoundTrigger


func _ready():
	sound_trigger_area.triggered.connect(set.bind("can_trigger", true))


func _on_body_entered(body):
	if body == Global.player and not triggered and can_trigger:
		triggered = true
		Global.monster.first_encounter_event(get_parent().get_node("MonsterEndPoint").global_position)
		AfflictionEffectController.override_effect_scale = true
		AfflictionEffectController.set_to_beyond_max_effect(3.0)
		sound_player.play()
		await get_tree().create_timer(10.0, false).timeout
		AfflictionEffectController.release_override(8.0)
