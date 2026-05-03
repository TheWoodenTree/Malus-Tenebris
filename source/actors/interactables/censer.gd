extends Interactable

const DEFAULT_LID_POS = Vector3(0.0, 0.555, 0.109)
const DEFAULT_LID_ROT = Vector3(-4.0, 0.0, 0.0)

var lid_closed := false
var can_reset := false

@onready var smoke_material_1: ShaderMaterial = $Smoke1.mesh.material
@onready var smoke_material_2: ShaderMaterial = $Smoke2.mesh.material
@onready var smoke_material_3: ShaderMaterial = $Smoke3.mesh.material
@onready var smoke_material_4: ShaderMaterial = $Smoke4.mesh.material
@onready var smoke_material_5: ShaderMaterial = $Smoke5.mesh.material
@onready var lid_close_player: AudioStreamPlayer3D = $LidClosePlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lid: MeshInstance3D = $Lid
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D


func _ready():
	super()
	SaveManager.loaded.connect(_on_loaded_from_save)
	GlobalSignals.player_entered_safe_room.connect(_on_player_entered_safe_room)
	GlobalSignals.player_exited_safe_room.connect(_on_player_exited_safe_room)


func _on_interact() -> void:
	if not lid_closed:
		animation_player.play("lid_close")
		lid_closed = true
		set_interactable(false)
		await animation_player.animation_finished
		set_interactable(true)
	
	SaveManager.save_game()
	Global.ui.show_hint("Progress saved", 3.0)
	var tween: Tween = create_tween()
	tween.tween_property(smoke_material_1, "shader_parameter/smokeHeight", 1.0, 7.5).from(0.0)
	tween.parallel().tween_property(smoke_material_2, "shader_parameter/smokeHeight", 1.0, 7.5).from(0.0)
	tween.parallel().tween_property(smoke_material_3, "shader_parameter/smokeHeight", 1.0, 7.5).from(0.0)
	tween.parallel().tween_property(smoke_material_4, "shader_parameter/smokeHeight", 1.0, 7.5).from(0.0)
	tween.parallel().tween_property(smoke_material_5, "shader_parameter/smokeHeight", 1.0, 7.5).from(0.0)
	pass


func reset():
	smoke_material_1.set_shader_parameter("smokeHeight", 0.0)
	smoke_material_2.set_shader_parameter("smokeHeight", 0.0)
	smoke_material_3.set_shader_parameter("smokeHeight", 0.0)
	smoke_material_4.set_shader_parameter("smokeHeight", 0.0)
	smoke_material_5.set_shader_parameter("smokeHeight", 0.0)
	lid.position = DEFAULT_LID_POS
	lid.rotation_degrees = DEFAULT_LID_ROT
	lid_closed = false


func _on_player_entered_safe_room():
	can_reset = false


func _on_player_exited_safe_room():
	await get_tree().create_timer(10.0, false).timeout
	if not Global.player.in_safe_room:
		can_reset = true
		if lid_closed:
			reset()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	if can_reset and not Global.player.in_safe_room:
		reset()


func _on_loaded_from_save():
	if lid_closed:
		smoke_material_1.set_shader_parameter("smokeHeight", 1.0)
		smoke_material_2.set_shader_parameter("smokeHeight", 1.0)
		smoke_material_3.set_shader_parameter("smokeHeight", 1.0)
		smoke_material_4.set_shader_parameter("smokeHeight", 1.0)
		smoke_material_5.set_shader_parameter("smokeHeight", 1.0)


func get_save_properties():
	var props: Array[String] = super()
	props.append_array([
		"can_reset",
		"lid_closed",
		"lid:position",
		"lid:rotation",
	])
	return props
