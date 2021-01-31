class_name OngoingWaveController
extends Spatial

export(Array, NodePath) var spawners
export(float) var spawn_delay = 2.0
export(int) var max_enemies = 10

var spawner_nodes := Array()
var spawn_count: int = 0
var death_count: int = 0
var is_active: bool = false

signal cleared_wave

func _ready() -> void:
	for spawner_path in spawners:
		var spawner = get_node(spawner_path)
		if ! spawner.has_method("spawn"):
			continue
		
		spawner_nodes.append(spawner)

func start_wave(other = null) -> void:
	is_active = true
	for spawner in spawner_nodes:
			spawner.connect("spawned_enemy", self, "track_enemy")
	
	while is_active:
		for spawner in spawner_nodes:
			if spawn_count - death_count < max_enemies:
				spawner.spawn()
			yield(get_tree().create_timer(spawn_delay), "timeout")

func stop_wave() -> void:
	is_active = false

func track_enemy(enemy):
	spawn_count += 1
	enemy.connect("just_died", self, "increase_death_count")

func increase_death_count() -> void:
	death_count += 1
	if is_active:
		return
	
	if death_count >= spawn_count:
		emit_signal("cleared_wave")
