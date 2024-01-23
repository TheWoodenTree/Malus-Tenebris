extends CharacterBody3D
class_name Character

const GRAVITY = 20.0
const ACCEL = 0.2

const CROUCH_DIST = -1.35

const CROUCH_TIME = 0.5

const WALK_SPEED = 4.0
const SPRINT_SPEED = 6.0
const CROUCH_SPEED = 2.0

const FOOTSTEP_WALK_INTERVAL = 0.65
const FOOTSTEP_SPRINT_INTERVAL = 0.43
const FOOTSTEP_CROUCH_INTERVAL = 0.98

const FOOTSTEP_WALK_VOL = -22.5
const FOOTSTEP_SPRINT_VOL = -17.5
const FOOTSTEP_CROUCH_VOL = -35.0

@export var gravity = GRAVITY
@export var accel = ACCEL

@export var crouch_dist = CROUCH_DIST
@export var crouch_time = CROUCH_TIME

@export var walk_speed = WALK_SPEED
@export var sprint_speed = SPRINT_SPEED
@export var crouch_speed = CROUCH_SPEED

@export var footstep_walk_interval = FOOTSTEP_WALK_INTERVAL
@export var footstep_sprint_interval = FOOTSTEP_SPRINT_INTERVAL
@export var footstep_crouch_interval = FOOTSTEP_CROUCH_INTERVAL

@export var footstep_walk_vol = FOOTSTEP_WALK_VOL
@export var footstep_sprint_vol = FOOTSTEP_SPRINT_VOL
@export var footstep_crouch_vol = FOOTSTEP_CROUCH_VOL

var sprinting = false
var moving = false
var moving_last_frame = false
var crouching = false
var crouch_trans = false
var in_water = false

var rng = RandomNumberGenerator.new()

var footstep_player_preload = preload("res://source/assets/sounds/walk/footstep_player.tscn")
var stone_footstep_sounds: Array
var wood_footstep_sounds: Array
var water_footstep_sounds: Array
var heavy_water_footstep_sounds: Array
var footstep_timer = Timer.new()
var footstep_vol_offset = 0.0
var speed_multiplier: float = 1.0

@onready var level = get_parent()
@onready var standing_collision = $standing_collision
@onready var crouching_collision = $crouching_collision
@onready var water_check = $water_check
@onready var floor_type_check = $floor_type_check


func _load_footsteps():
	for i in range(1, 4):
		var file_path = "res://source/assets/sounds/walk/stone_footstep_%d.ogg" % i
		var sound = load(file_path)
		stone_footstep_sounds.append(sound)
	for i in range(1, 4):
		var file_path = "res://source/assets/sounds/walk/wood_footstep_%d.ogg" % i
		var sound = load(file_path)
		wood_footstep_sounds.append(sound)
	for i in range(1, 4):
		var file_path = "res://source/assets/sounds/walk/water_footstep_%d.ogg" % i
		var sound = load(file_path)
		water_footstep_sounds.append(sound)
	for i in range(1, 4):
		var file_path = "res://source/assets/sounds/walk/heavy_water_footstep_%d.ogg" % i
		var sound = load(file_path)
		heavy_water_footstep_sounds.append(sound)


func _play_footstep_sound():
	var floor_type: Block.FloorType
	var footstep_sounds: Array
	if in_water:
		footstep_sounds = heavy_water_footstep_sounds
	elif floor_type_check.get_collider() is Block:
		floor_type = floor_type_check.get_collider().type
		if floor_type == Block.FloorType.STONE:
			footstep_sounds = stone_footstep_sounds
			footstep_vol_offset = 0.0
		elif floor_type == Block.FloorType.WOOD:
			footstep_sounds = wood_footstep_sounds
			footstep_vol_offset = 0.0
	else:
		footstep_sounds = stone_footstep_sounds
		
		
	rng.randomize()
	var footstep_player = footstep_player_preload.instantiate()
	var volume: float
	if not sprinting and not crouching:
		volume = footstep_walk_vol + footstep_vol_offset
	elif sprinting and not crouching:
		volume = footstep_sprint_vol + footstep_vol_offset
	elif crouching:
		volume = footstep_crouch_vol + footstep_vol_offset
	footstep_player.volume_db = volume
		
	if not in_water:
		footstep_player.stream = footstep_sounds[rng.randi_range(0, 2)]
		footstep_player.pitch_scale = randf_range(0.8, 1.2)
	else:
		footstep_player.volume_db -= 5
		footstep_player.stream = heavy_water_footstep_sounds[rng.randi_range(0, 2)]
		footstep_player.pitch_scale = randf_range(0.75, 0.9)
	
	# Adding the audio player to the world rather than the player causes an audio
	# bug that makes the sound play multiple times at once when crouching
	add_child(footstep_player)
	footstep_player.position += Vector3.DOWN * 0.5 * standing_collision.shape.height
	footstep_player.play()
	footstep_timer.start()
