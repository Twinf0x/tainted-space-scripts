class_name PowerLineController
extends Node

export(Material) var inactive_material
export(Material) var active_material
export(Array, NodePath) var power_line_paths

signal activated

var power_line = Array()
var is_active: bool = false

func _ready():
	for path in power_line_paths:
		var node = get_node(path)
		node.material = inactive_material
		power_line.append(node)

func activate() -> void:
	if is_active:
		return
	
	for node in power_line:
		node.material = active_material
	
	is_active = true
	emit_signal("activated")
