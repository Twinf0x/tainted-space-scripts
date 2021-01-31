class_name SelfDestructor
extends Node

export var lifetime = 5

func _ready():
	yield(get_tree().create_timer(lifetime), "timeout")
	queue_free()
