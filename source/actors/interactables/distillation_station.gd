extends Node3D

@onready var distillation_bottle = $distillation_bottle
@onready var distillate_cup = $distillate_cup


func _ready():
	distillation_bottle.vial_used.connect(distillate_cup.distillation_started)
	distillate_cup.done_pouring.connect(distillation_bottle.distillation_complete)
