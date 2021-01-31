class_name PowerLineCounter
extends Node

export(Array, NodePath) var power_line_paths

var activation_counter: int = 0
var all_activated: bool = false

signal all_power_lines_activated

func _ready():
	for path in power_line_paths:
		var node = get_node(path)
		node.connect("activated", self, "on_activation")

func on_activation() -> void:
	if all_activated:
		return
	
	activation_counter += 1
	if activation_counter >= power_line_paths.size():
		all_activated = true
		emit_signal("all_power_lines_activated")
