extends Node

##########################
# GLOBAL SOUND CONSTANTS #
##########################

const DEF_DRONE_VOLUME: float = -10.0
const DEF_DRIP_VOLUME: float = -30.0
const DEF_FOOTSTEP_VOLUME_OFFSET: float = 0.0
const DEF_TORCH_BURN_VOLUME: float = 0.0
const DEF_FOOTSTEP_REVERB_ROOM_SIZE: float = 0.8
const DEF_FOOTSTEP_REVERB_WET: float = 0.8

const TENSION_DRONE_VOLUME: float = -80.0
const TENSION_DRIP_VOLUME: float = -40.0
const TENSION_FOOTSTEP_VOLUME_OFFSET: float = 10.0
const TENSION_TORCH_BURN_VOLUME: float = 6.0
const TENSION_FOOTSTEP_REVERB_ROOM_SIZE: float = 0.2
const TENSION_FOOTSTEP_REVERB_WET: float = 0.1


# Lower volume of drone, decrease reverb, and increase volume of player footsteps
# in an effort to make the player require anxiety medication
func enable_tension(time):
	var tween = get_tree().create_tween()
	tween.tween_property(Global.main.drone_player, "volume_db", \
		TENSION_DRONE_VOLUME, time)
	tween.parallel().tween_property(Global.main.drip_player, "volume_db", \
		TENSION_DRIP_VOLUME, time)
	tween.parallel().tween_property(Global.player, "footstep_vol_offset", \
		TENSION_FOOTSTEP_VOLUME_OFFSET, time)
	if Global.player.has_torch:
		tween.parallel().tween_property(Global.player.torch.burning_player, "volume_db", \
			TENSION_TORCH_BURN_VOLUME, time)
	tween.parallel().tween_property(AudioServer.get_bus_effect(7, 0), "room_size", \
		TENSION_FOOTSTEP_REVERB_ROOM_SIZE, time)
	tween.parallel().tween_property(AudioServer.get_bus_effect(7, 0), "wet", \
		TENSION_FOOTSTEP_REVERB_WET, time)


# Reverse effects of the above function
func disable_tension(time):
	var tween = get_tree().create_tween()
	tween.tween_property(Global.main.drone_player, "volume_db", \
		DEF_DRONE_VOLUME, time)
	tween.parallel().tween_property(Global.main.drip_player, "volume_db", \
		DEF_DRIP_VOLUME, time)
	tween.parallel().tween_property(Global.player, "footstep_vol_offset", \
		DEF_FOOTSTEP_VOLUME_OFFSET, time)
	if Global.player.has_torch:
		tween.parallel().tween_property(Global.player.torch.burning_player, "volume_db", \
			DEF_TORCH_BURN_VOLUME, time)
	tween.parallel().tween_property(AudioServer.get_bus_effect(1, 0), "room_size", \
		DEF_FOOTSTEP_REVERB_ROOM_SIZE, time)
	tween.parallel().tween_property(AudioServer.get_bus_effect(1, 0), "wet", \
		DEF_FOOTSTEP_REVERB_WET, time)
