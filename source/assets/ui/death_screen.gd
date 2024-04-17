extends Menu

@onready var anim_player: AnimationPlayer = $anim_player
@onready var background: Sprite2D = $background


func _ready():
	Global.player.in_menu = true
	anim_player.play("death_screen_anim")


func set_shader_vignette_mult(value: float):
	background.material.set_shader_parameter("vigMultiplier", value)


func call_unlock_mouse():
	Global.unlock_mouse()
