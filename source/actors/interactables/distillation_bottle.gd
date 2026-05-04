extends Interactable

@warning_ignore("unused_signal")
signal vial_used

var has_been_interacted_with: bool = false

@onready var pour_particles = $PourParticles
@onready var pour_anim_player = $PourAnimPlayer
@onready var vial = $Vial


func _ready() -> void:
	super()


func _on_interact() -> void:
	if Global.player.is_holding_item(ItemRegistry.ID.RUBOLEUM_VIAL):
		has_been_interacted_with = true
		
		set_interactable(false)
		
		var initial_pos: Vector3 = vial.global_position
		var initial_rot: Vector3 = vial.global_rotation
		
		var held_item: Pickup = Global.player.held_item
		vial.global_position = held_item.global_position
		vial.global_rotation = held_item.meshes[0].global_rotation
		
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(vial, "global_position", initial_pos, 0.35)
		tween.parallel().tween_property(vial, "global_rotation", initial_rot, 0.35)
		
		vial.mesh.surface_get_material(0).albedo_color.a = 1.0
		vial.visible = true
		vial.layers = 2
		Global.player.delete_held_item()
		
		await tween.finished
		vial.layers = 1
		pour_anim_player.play("pour")
	elif not has_been_interacted_with:
		Global.ui.show_hint_popup("Distill ruboleum found throughout the\nprison to reduce the effects of Vitriscet")
	else:
		Global.ui.show_hint("Need Ruboleum for distillation", 3.0)


func distillation_complete():
	pour_particles.emitting = false
	if pour_anim_player.is_playing():
		await pour_anim_player.animation_finished
	set_interactable(true)
