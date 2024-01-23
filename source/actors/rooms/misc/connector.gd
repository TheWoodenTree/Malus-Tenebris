extends Node3D

@onready var hanging_lamp = $hanging_lamp

@export var lamp_lit: bool = true


func _ready():
	hanging_lamp.set_lit(lamp_lit)
