extends Pickup

@export var test_time_scale: float = 1.0 : set = test

@onready var sand_top_shader: ShaderMaterial = $SandTop.mesh.surface_get_material(0)
@onready var sand_bottom_shader: ShaderMaterial = $SandBottom.mesh.surface_get_material(0)
@onready var sand_particles: CPUParticles3D = $SandParticles
@onready var sand_top_cap_shader: ShaderMaterial = $SandBottomCap.mesh.surface_get_material(0)
@onready var sand_bottom_cap_shader: ShaderMaterial = $SandBottomCap.mesh.surface_get_material(0)


func _ready():
	super()
	AfflictionTimer.started.connect(func(): sand_particles.emitting = true)
	AfflictionTimer.stopped.connect(func(): sand_particles.emitting = false)
	AfflictionTimer.timeout.connect(func(): sand_particles.emitting = false)
	AfflictionTimer.time_scale_changed.connect(_on_timescale_change)


func _process(_delta: float) -> void:
	if Global.player.is_holding_hourglass:
		var fill_proportion: float = AfflictionTimer.time_left / AfflictionTimer.MAX_AFFLICTION_TIMER_VALUE
		sand_top_shader.set_shader_parameter('fill_proportion', fill_proportion)
		sand_bottom_shader.set_shader_parameter('fill_proportion', 1.0 - fill_proportion)
		sand_top_cap_shader.set_shader_parameter('fill_proportion', fill_proportion)
		sand_bottom_cap_shader.set_shader_parameter('fill_proportion', 1.0 - fill_proportion)


func _on_interact():
	super()


func _on_timescale_change(time_scale: float):
	sand_particles.amount = int(3.0 * time_scale)


func test(testt):
	test_time_scale = testt
	AfflictionTimer.time_scale = test_time_scale
