class_name FlickeringLight
extends Light

var rng = RandomNumberGenerator.new()
var wait_time: float

func _ready():
	start_flickering()

func start_flickering():
	while true:
		set_param(Light.PARAM_ENERGY, 0.0)
		rng.randomize()
		wait_time = rng.randf_range(0.1, 0.3)
		yield(get_tree().create_timer(wait_time), "timeout")
		set_param(Light.PARAM_ENERGY, 1.0)
		rng.randomize()
		wait_time = rng.randf_range(0.2, 5.0)
		yield(get_tree().create_timer(1.0), "timeout")
