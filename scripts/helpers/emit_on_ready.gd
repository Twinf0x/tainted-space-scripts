class_name EmitOnReady
extends Particles

export var stop_after = -1.0

func _ready():
	restart()
	if stop_after > 0:
		yield(get_tree().create_timer(stop_after), "timeout")
		emitting = false
