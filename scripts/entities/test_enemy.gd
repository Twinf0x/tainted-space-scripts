class_name TestEnemy
extends KinematicBody

export var speed = 3.5
export var attack_range = 1

onready var animation_player = $AnimationPlayer
onready var raycast = $RayCast

var player = null
var dead = false

func _ready():
	animation_player.play("walk")
	add_to_group("enemies")
 
func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
 
	var player_direction = (player.translation - translation).normalized()
	raycast.cast_to = player_direction * attack_range
 
	move_and_collide(player_direction * speed * delta)
 
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll != null and coll.name == "Player":
			coll.on_death()
 
 
func kill():
	dead = true
	$CollisionShape.disabled = true
	animation_player.play("die")
 
func set_player(p):
	player = p
