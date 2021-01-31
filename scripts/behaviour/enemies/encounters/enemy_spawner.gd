class_name EnemySpawner
extends Spatial

export(Array, PackedScene) var enemy_templates
export(Array, PackedScene) var spawn_effect_templates
export var spawn_delay = 1
export var enemy_spawns_active = true

var rng = RandomNumberGenerator.new()
var spawn_sfx

signal spawned_enemy(enemy_node)

func spawn():
	rng.randomize()
	spawn_effect()
	yield(get_tree().create_timer(spawn_delay), "timeout")
	spawn_sfx.play()
	var enemy = spawn_enemy()
	emit_signal("spawned_enemy", enemy)

func spawn_effect():
	var effect = spawn_effect_templates[rng.randi_range(0, spawn_effect_templates.size() - 1)].instance()
	effect.translation = global_transform.origin
	get_tree().root.add_child(effect)
	spawn_sfx = effect.get_node("SummonSFX")

func spawn_enemy() -> Node:
	var enemy = enemy_templates[rng.randi_range(0, enemy_templates.size() - 1)].instance()
	enemy.translation = global_transform.origin
	get_tree().root.add_child(enemy)
	enemy.is_activated = enemy_spawns_active
	
	return enemy
