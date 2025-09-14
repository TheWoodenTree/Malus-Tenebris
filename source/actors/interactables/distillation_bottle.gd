extends Interactable

@onready var pour_particles = $PourParticles
@onready var pour_anim_player = $PourAnimPlayer
@onready var vial = $Vial

@warning_ignore("unused_signal")
signal vial_used


func _ready() -> void:
	super()


func _on_interact() -> void:
	if Global.player.is_holding_item("Ruboleum Vial"):
		set_interactable(false)
		
		var initial_pos: Vector3 = vial.global_position
		var initial_rot: Vector3 = vial.global_rotation
		vial.global_position = Global.player.held_item.global_position
		vial.global_rotation = Global.player.held_item.global_rotation
		
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
	else:
		Global.ui.hint_popup("Need Ruboleum for distillation", 3.0)


func distillation_complete():
	pour_particles.emitting = false
	set_interactable(true)
