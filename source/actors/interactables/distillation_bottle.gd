extends Interactable

@onready var interact_area = $interact_area
@onready var pour_particles = $pour_particles
@onready var pour_anim_player = $pour_anim_player
@onready var vial = $vial
@onready var mesh = $mesh

signal vial_used


func _ready():
	super()
	init(Type.MISC, interact_area, [mesh])


func _process(_delta):
	if interactable and being_looked_at:
		mesh.material_overlay.set_shader_parameter("outlineOn", true)
		outline_on = true
	elif outline_on:
		mesh.material_overlay.set_shader_parameter("outlineOn", false)
		outline_on = false


func interact():
	if Global.player.is_holding_item("Ruboleum Vial"):
		set_interactable(false)
		
		var initial_pos: Vector3 = vial.global_position
		var initial_rot: Vector3 = vial.global_rotation
		vial.global_position = Global.player.held_item_mesh.global_position
		vial.global_rotation = Global.player.held_item_mesh.global_rotation
		
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
