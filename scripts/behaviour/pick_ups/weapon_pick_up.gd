class_name WeaponPickUp
extends Area

export(PackedScene) var weapon

onready var animation_player = $AnimationPlayer

signal picked_up

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
	
	return true

func pick_up(other):
	var weapon_node = weapon.instance()
	other.weapons_controller.add_weapon(weapon_node)
	emit_signal("picked_up")
