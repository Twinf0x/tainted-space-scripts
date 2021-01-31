class_name HealthDisplay
extends TextureProgress

export(NodePath) var target

onready var destructable = get_node(target)

func _ready():
	max_value = destructable.max_health
	value = destructable.current_health

func _process(delta):
	value = destructable.current_health
