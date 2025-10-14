class_name Bandage
extends SelfUseable

const HEAL_AMOUNT = 5.0


func use():
	Global.player.heal(HEAL_AMOUNT)
	Global.player.play_sound_one_shot(use_sound)
	Global.player.delete_held_item()
