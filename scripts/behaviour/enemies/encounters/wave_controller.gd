class_name WaveController
extends Node

export(Array, NodePath) var spawners
export(int) var needed_death_count = -1
export(float) var next_wave_time = -1
export(float) var spawn_delay = 0.1

var spawner_nodes := Array()
var death_count: int = 0

var wave_has_started: bool = false
var next_wave_triggered: bool = false

signal next_wave
signal cleared_wave

func _ready() -> void:
	for spawner_path in spawners:
		var spawner = get_node(spawner_path)
		if ! spawner.has_method("spawn"):
			continue
		
		spawner_nodes.append(spawner)

func start_wave(other = null) -> void:
	if wave_has_started:
		return
	
	if other != null && !(other is PlayerController):
		return
	
	wave_has_started = true
	for spawner in spawner_nodes:
		spawner.connect("spawned_enemy", self, "track_enemy")
		spawner.spawn()
		yield(get_tree().create_timer(spawn_delay), "timeout")
	
	if next_wave_time > 0:
		yield(get_tree().create_timer(next_wave_time), "timeout")
		next_wave()

func track_enemy(enemy):
	enemy.connect("just_died", self, "increase_death_count")

func increase_death_count() -> void:
	death_count += 1
	if needed_death_count > 0 && death_count >= needed_death_count:
		next_wave()
	if death_count >= spawner_nodes.size():
		emit_signal("cleared_wave")

func next_wave():
	if !next_wave_triggered:
		for spawner in spawner_nodes:
			spawner.disconnect("spawned_enemy", self, "track_enemy")
		emit_signal("next_wave")
		next_wave_triggered = true
