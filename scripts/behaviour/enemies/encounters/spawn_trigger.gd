class_name SpawnTrigger
extends Node

export(Array, NodePath) var spawners
export var is_active = true

signal trigger_spawn

func _ready() -> void:
	for spawner_path in spawners:
		var spawner = get_node(spawner_path)
		if ! spawner.has_method("spawn"):
			continue
		
		connect("trigger_spawn", spawner, "spawn")
	
	connect("body_entered", self, "check_trigger")

func check_trigger(other) -> void:
	if !is_active || !(other is PlayerController):
		return
	
	emit_signal("trigger_spawn")
	is_active = false
