class_name AmmoPickUp
extends Area

export var for_weapon = "weapon name"
export var contained_ammo = 30

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
	
	if !other.can_pick_up_ammo_for(for_weapon):
		return false
	
	return true

func pick_up(other):
	other.add_ammo(for_weapon, contained_ammo)
