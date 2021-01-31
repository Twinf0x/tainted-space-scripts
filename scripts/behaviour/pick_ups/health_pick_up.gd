class_name HealthPickUp
extends Area

export var heal_by = 30

onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("idle")
	connect("body_entered", self, "try_pick_up")

func try_pick_up(other):
	if can_pick_up(other):
		pick_up(other)
		queue_free()

func can_pick_up(other) -> bool:
	if other.name != "Player":
		return false
	
	if other.destructable.has_full_health():
		return false
	
	return true

func pick_up(other):
	other.heal_by(heal_by)
