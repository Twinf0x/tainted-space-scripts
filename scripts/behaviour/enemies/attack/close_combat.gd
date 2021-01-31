class_name CloseCombat
extends Node

export var attack_range = 1.5
export var attack_damage = 10
export var attack_time = 1.0
export(NodePath) var raycast_node

signal start_attack
signal finish_attack

onready var raycast = get_node(raycast_node)
onready var player = get_node("/root/GameController").player
onready var sfx = $SFX

func attack():
	if player == null:
		return
	
	var player_direction = (player.translation - get_parent().translation)
	player_direction.y = 0
	player_direction = player_direction.normalized()
	raycast.cast_to = player_direction * attack_range
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target != null and target.name == "Player":
			sfx.play()
			target.take_damage(attack_damage)
			emit_signal("start_attack")
			yield(get_tree().create_timer(attack_time), "timeout")
			emit_signal("finish_attack")

func set_player(p):
	player = p
