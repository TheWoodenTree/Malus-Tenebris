class_name StateMachine
extends Node

@export var character: CharacterBody3D
@export var initial_state: State

var current_state: State
var states: Dictionary[String, State] = {}


func _ready() -> void:
	await get_parent().ready
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.set_character(character)
			child.transition.connect(_on_state_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _on_state_transition(from_state: State, to_state_name: String) -> void:
	if from_state != current_state:
		return
	
	var to_state: State = states[to_state_name]
	if not to_state:
		return
	
	if current_state:
		current_state.exit()
	
	to_state.enter()
	
	current_state = to_state
