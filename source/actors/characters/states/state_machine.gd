class_name StateMachine
extends Node

signal state_updated(state: State)

@export var character: Character
@export var initial_state: State
@export var initial_state_params: Dictionary

var current_state: State : 
	set(state): 
		current_state = state
		state_updated.emit(current_state)

var states: Dictionary[String, State] = {}


func _ready() -> void:
	await get_parent().ready
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.set_character(character)
			child.transitioned.connect(_on_state_transitioned)
	
	character.state_change_requested.connect(_on_state_change_requested)
	
	if initial_state:
		initial_state.enter({})
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _on_state_transitioned(from_state: State, to_state_name: String, params: Dictionary = {}) -> void:
	if from_state != current_state:
		return
	
	var to_state: State = states[to_state_name]
	_change_state(to_state, params)


func _on_state_change_requested(state_name: String, params: Dictionary = {}) -> void:
	var state: State = states[state_name]
	_change_state(state, params)


func _change_state(new_state: State, params: Dictionary):
	if new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter(params)
	
	current_state = new_state
