extends Interactable

var num_doses: int = 1
var first_dose: bool = true

@onready var mesh = $mesh
@onready var interact_area = $interact_area
@onready var pour_player = $pour_player


signal done_pouring


func _ready():
	init(Type.MISC, interact_area)


func _process(_delta):
	if interactable and being_looked_at:
		mesh.material_overlay.set_shader_parameter("outlineOn", true)
		if num_doses > 0 and not outline_on:
			if not first_dose:
				var doses_left_string: String = ("Contains %d " % num_doses) + ("dose" if num_doses == 1 else "doses")
				Global.ui.hint_popup(doses_left_string, -1)
			else:
				Global.ui.hint_popup("Interact to drink the temporary cure", -1)
		outline_on = true
	elif outline_on:
		mesh.material_overlay.set_shader_parameter("outlineOn", false)
		Global.ui.hint_remove()
		outline_on = false


func interact():
	if first_dose:
		Global.ui.hint_remove()
		first_dose = false
		
	if num_doses > 0:
		num_doses -= 1
		if num_doses > 0:
			var doses_left_string: String = ("Contains %d " % num_doses) + ("dose" if num_doses == 1 else "doses")
			Global.ui.hint_popup(doses_left_string, -1)
		else:
			Global.ui.hint_remove()
		Global.player.play_noise_player()
	else:
		Global.ui.hint_popup("It's empty", 3.0)


func distillation_started():
	set_interactable(false)
	pour_player.play()
	await pour_player.finished
	emit_signal("done_pouring")
	num_doses += 1
	set_interactable(true)