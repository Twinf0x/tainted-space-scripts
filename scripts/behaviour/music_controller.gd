class_name MusicController
extends Node

export(NodePath) var ambience_path
export(Array, NodePath) var battle_paths
export(NodePath) var battle_finish_path
export(NodePath) var boss_battle_path
export(NodePath) var heartbeat_path
export(NodePath) var footsteps_path
export(NodePath) var victory_player_path

var ambience_player
var battle_players
var battle_index = 0
var battle_finish_player
var boss_battle_player
var heartbeat_player
var footsteps_player
var victory_player

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	ambience_player = get_node(ambience_path)
	battle_finish_player = get_node(battle_finish_path)
	boss_battle_player = get_node(boss_battle_path)
	heartbeat_player = get_node(heartbeat_path)
	footsteps_player = get_node(footsteps_path)
	victory_player = get_node(victory_player_path)
	
	battle_players = Array()
	for path in battle_paths:
		battle_players.append(get_node(path))

func start_battle() -> void:
	if battle_players[battle_index].playing:
		return
	
	rng.randomize()
	battle_index = rng.randi_range(0, battle_players.size() - 1)
	battle_players[battle_index].play()

func stop_battle() -> void:
	battle_players[battle_index].stop()

func finish_battle() -> void:
	if battle_finish_player.playing:
		return
	battle_finish_player.play()

func start_boss() -> void:
	if boss_battle_player.playing:
		return
	
	boss_battle_player.play()

func stop_boss() -> void:
	boss_battle_player.stop()

func start_victory() -> void:
	victory_player.play()

func start_footsteps() -> void:
	if footsteps_player.playing:
		return
	
	footsteps_player.play()

func stop_footsteps():
	footsteps_player.stop()

func start_heartbeat() -> void:
	if heartbeat_player.playing:
		return
	
	# reduce volume of all others
	ambience_player.volume_db -= 6.0
	battle_finish_player.volume_db -= 6.0
	boss_battle_player.volume_db -= 6.0
	footsteps_player.volume_db -= 6.0
	for player in battle_players:
		player.volume_db -= 6.0
	
	heartbeat_player.play()

func stop_heartbeat() -> void:
	if !heartbeat_player.playing:
		return
	
	# turn the volume of all others back up again
	ambience_player.volume_db += 6.0
	battle_finish_player.volume_db += 6.0
	boss_battle_player.volume_db += 6.0
	footsteps_player.volume_db += 6.0
	for player in battle_players:
		player.volume_db += 6.0
	
	heartbeat_player.stop()
