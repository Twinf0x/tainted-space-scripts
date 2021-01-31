class_name EnemyController
extends KinematicBody

export(PackedScene) var blood_template
export var detection_range = 10

onready var destructable = $Destructable
onready var movement = $Movement
onready var attack = $Attack
onready var animation_player = $AnimationPlayer
onready var death_sfx = $DeathSFX
onready var player = get_node("/root/GameController").player

var is_dead = false
var is_attacking = false
var is_activated = false

signal just_died
signal detected_player

func _ready():
	attack.connect("start_attack", self, "on_start_attack")
	attack.connect("finish_attack", self, "on_finish_attack")

func _physics_process(delta):
	if is_dead || is_attacking:
		return
	
	if !is_activated:
		if !can_detect_player():
			return
	
	var did_move = movement.move(delta)
	if did_move && animation_player.current_animation != "walk":
		animation_player.play("walk")
		
	attack.attack()

func can_detect_player() -> bool:
	if player_is_in_range() && player_is_in_sight():
		is_activated = true
		emit_signal("detected_player")
		return true
	else:
		return false

func player_is_in_range() -> bool:
	return (player.translation - global_transform.origin).length() <= detection_range

func player_is_in_sight() -> bool:
	var space_state = get_world().direct_space_state
	# TODO: might have a problem here, where the raycast always intersects with the floor
	var ray_result = space_state.intersect_ray(global_transform.origin, player.translation, [get_parent()])
	if ray_result.empty():
		return false
	if ray_result.collider is PlayerController:
		return true
	return false

# Implement wrapper for destructable
func take_damage(amount, hit_position):
	if !is_activated:
		is_activated = true
		emit_signal("detected_player")
	destructable.take_damage(amount)
	var particles = blood_template.instance()
	get_tree().root.add_child(particles)
	particles.global_transform.origin = hit_position
	particles.global_transform.basis = global_transform.basis

func on_death():
	if is_dead:
		return
	
	is_dead = true
	death_sfx.play()
	$CollisionShape.disabled = true
	emit_signal("just_died")
	animation_player.play("die")

func on_start_attack():
	animation_player.play("attack")
	is_attacking = true

func on_finish_attack():
	is_attacking = false
