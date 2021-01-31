class_name SelfRotator
extends Spatial

export(float) var degrees_per_second

const DEG2RAD = 0.01745329252

func _process(delta):
	#transform = transform.rotated(Vector3(0, 0, 1), degrees_per_second * DEG2RAD * delta)
	global_rotate(Vector3(0, 1, 0), degrees_per_second * DEG2RAD * delta)
