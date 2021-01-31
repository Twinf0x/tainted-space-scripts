class_name MultipleDoorController
extends Spatial

export(Array, NodePath) var door_paths

var doors = Array()

func _ready() -> void:
	for path in door_paths:
		var door = get_node(path)
		doors.append(door)

func open() -> void:
	for door in doors:
		door.open()

func close() -> void:
	for door in doors:
		door.close()
