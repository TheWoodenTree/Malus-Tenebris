extends Pickup

@onready var sand_top_shader: ShaderMaterial = $SandTop.mesh.surface_get_material(0)
@onready var sand_bottom_shader: ShaderMaterial = $SandBottom.mesh.surface_get_material(0)
@onready var sand_particles: CPUParticles3D = $SandParticles
@onready var sand_top_cap_shader: ShaderMaterial = $SandBottomCap.mesh.surface_get_material(0)
@onready var sand_bottom_cap_shader: ShaderMaterial = $SandBottomCap.mesh.surface_get_material(0)


func _process(_delta: float) -> void:
	var fill_proportion: float = AfflictionTimer.time_left / AfflictionTimer.MAX_AFFLICTION_TIMER_VALUE
	sand_top_shader.set_shader_parameter('fill_proportion', fill_proportion)
	sand_bottom_shader.set_shader_parameter('fill_proportion', 1.0 - fill_proportion)
	sand_top_cap_shader.set_shader_parameter('fill_proportion', fill_proportion)
	sand_bottom_cap_shader.set_shader_parameter('fill_proportion', 1.0 - fill_proportion)


func _ready():
	super()
	AfflictionTimer.started.connect(func(): sand_particles.emitting = true)
	AfflictionTimer.stopped.connect(func(): sand_particles.emitting = false)


func _on_interact():
	super()
