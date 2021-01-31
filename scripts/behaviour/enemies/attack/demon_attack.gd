class_name DemonAttack
extends Spatial

signal start_attack
signal finish_attack

export var min_projectile_attack_distance: float = 7.0

onready var close_combat = $CloseCombat
onready var projectile_attack = $ProjectileAttack
onready var animation_player = $"../AnimationPlayer"
onready var player = get_node("/root/GameController").player

var is_attacking: bool = false

func _ready():
	close_combat.connect("start_attack", self, "on_start_close_combat")
	close_combat.connect("finish_attack", self, "on_finish_close_combat")
	projectile_attack.connect("start_attack", self, "on_start_shooting")
	projectile_attack.connect("finish_attack", self, "on_finish_shooting")

func attack():
	if is_attacking:
		return
	close_combat.attack()
	
	if is_attacking:
		return
	projectile_attack.attack()

func can_shoot() -> bool:
	return (player.translation - global_transform.origin).length() >= min_projectile_attack_distance

func on_start_close_combat():
	is_attacking = true
	emit_signal("start_attack")
	animation_player.play("slash")

func on_start_shooting():
	is_attacking = true
	emit_signal("start_attack")
	animation_player.play("shoot")

func on_finish_close_combat():
	is_attacking = false
	emit_signal("finish_attack")

func on_finish_shooting():
	is_attacking = false
	emit_signal("finish_attack")
