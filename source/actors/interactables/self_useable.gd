class_name SelfUseable
extends Node

var useable: bool = true
var used: bool = false
var held_before: bool = false


# Overloaded by child script
func use():
	pass
