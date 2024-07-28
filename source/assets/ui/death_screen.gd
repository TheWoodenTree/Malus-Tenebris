extends Menu

@onready var anim_player: AnimationPlayer = $anim_player
@onready var background: Sprite2D = $background


func _ready():
	Global.player.in_menu = true
	anim_player.play("death_screen_anim")


func _on_title_screen_button_pressed():
	Global.main.heartbeat_player.volume_db = -30.0
	Global.vignette_shader.set_shader_parameter("multiplier", 0.15)
	Global.vignette_shader.set_shader_parameter("softness", 2.0)
	Global.zoom_shader.set_shader_parameter("intensity", 0.0)
	Global.world.queue_free()
	Global.ui.remove_menu()
	Global.main.load_title_screen()


func _on_quit_button_pressed():
	get_tree().quit()


func set_shader_vignette_mult(value: float):
	background.material.set_shader_parameter("vigMultiplier", value)


func call_unlock_mouse():
	Global.unlock_mouse()
