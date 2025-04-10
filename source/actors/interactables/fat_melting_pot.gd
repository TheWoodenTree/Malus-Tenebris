extends Interactable

var fat_being_melted: bool = false
var fat_melted: bool = false
var key_dipped: bool = false

@onready var fat = $Fat
@onready var key = $Key
@onready var key_pickup_player = $KeyPickupPlayer
@onready var anim_player = $AnimPlayer

@export var key_item_data: ItemData


func _ready():
	super()
	key_item_data.mesh = key.get_node("Mesh").duplicate()


func _melt_fat():
	var initial_rot: Vector3 = fat.global_rotation
	fat.global_position = Global.player.held_item.global_position
	fat.global_rotation = Global.player.held_item.global_rotation
	var initial_pos: Vector3 = anim_player.get_animation("melt_fat").track_get_key_value(0, 0)
	Global.player.delete_held_item()
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(fat, "global_position", to_global(initial_pos), 0.35)
	tween.parallel().tween_property(fat, "global_rotation", initial_rot, 0.35)
	
	fat.visible = true
	fat.layers = 2
	set_interactable(false)
	
	await tween.finished
	set_interactable(true)
	fat_being_melted = true
	fat.layers = 1
	anim_player.play("melt_fat")
	
	await anim_player.animation_finished


func _lube_key():
	var initial_rot: Vector3 = key.global_rotation
	key.global_position = Global.player.held_item.global_position
	key.global_rotation = Global.player.held_item.global_rotation
	var initial_pos: Vector3 = anim_player.get_animation("dip_key").track_get_key_value(0, 0)
	Global.player.delete_held_item()
	
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(key, "global_position", to_global(initial_pos), 0.35)
	tween.parallel().tween_property(key, "global_rotation", initial_rot, 0.35)
	
	key.visible = true
	key.get_node("Mesh").layers = 2
	set_interactable(false)
	
	await tween.finished
	key.get_node("Mesh").layers = 1
	anim_player.play("dip_key")
	
	await anim_player.animation_finished
	key_dipped = true
	set_interactable(true)


func interact():
	if not fat_being_melted and not fat_melted and not key_dipped:
		if Global.player.is_holding_item("Beef Fat"):
			_melt_fat()
		else:
			Global.ui.hint_popup("Not holding anything to cook", 3.0)
	elif fat_being_melted and not fat_melted and not key_dipped:
		Global.ui.hint_popup("The fat will take a while to be rendered", 3.0)
	elif fat_melted and not key_dipped:
		if Global.player.is_holding_item("Prison Depths Key"):
			_lube_key()
		else:
			if Global.player.held_item_data:
				Global.ui.hint_popup("There's no point to dipping that in the tallow", 3.0)
			else:
				Global.ui.hint_popup("Not holding anything to dip in the tallow", 3.0)
	elif fat_melted and key_dipped:
		Global.player.inventory_add_item(key_item_data)
		Global.ui.hint_popup("Picked up %s" % key_item_data.name, 3.0)
		Global.player.play_pickup_sound(key_pickup_player)
		set_interactable(false)
