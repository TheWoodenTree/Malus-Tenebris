extends Node

const POOL_SIZE = 8

var _players: Array[AudioStreamPlayer] = []
var _3D_players: Array[AudioStreamPlayer3D] = []


func _ready() -> void:
	for i in POOL_SIZE:
		var player = AudioStreamPlayer.new()
		var player_3D = AudioStreamPlayer3D.new()
		add_child(player)
		add_child(player_3D)
		_players.append(player)
		_3D_players.append(player_3D)


func play(stream: AudioStream) -> void:
	for player in _players:
		if not player.playing:
			player.stream = stream
			player.play()
			return


func play_3d(stream: AudioStream, pos: Vector3) -> void:
	for player in _3D_players:
		if not player.playing:
			player.stream = stream
			player.global_position = pos
			player.play()
			return
