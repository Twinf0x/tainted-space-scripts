class_name LightController
extends Node

export(Array, NodePath) var light_paths

var lights = Array()

func _ready():
	for path in light_paths:
		lights.append(get_node(path))

func turn_on() -> void:
	for light in lights:
		light.visible = true

func turn_off() -> void:
	for light in lights:
		light.visible = false
