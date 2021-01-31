class_name MoveTowardsPlayer
extends Node

export var speed = 3.5
onready var player = get_node("/root/GameController").player

func move(delta):
	if player == null:
		return false
		
	var player_direction = (player.translation - get_parent().translation).normalized()
	get_parent().move_and_collide(player_direction * speed * delta)
	return true

func set_player(p):
	player = p
