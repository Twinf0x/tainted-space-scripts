class_name ProjectileAttack
extends Spatial

export var attack_range = 15
export var damage_per_projectile = 10
export var number_of_projectiles = 1
export var projectile_speed = 10.0
export var projectile_lifetime = 8.0
# The attack may target a point with this distance (in units in the XZ-Plane) around the player
export var projectile_spread = 0.0
export var wind_up_time = 0.15
export var attack_duration = 0.6
export var attack_cooldown = 3.0
export(PackedScene) var projectile_template

signal start_attack
signal finish_attack

onready var player = get_node("/root/GameController").player
onready var fire_point = $FirePoint
onready var sfx = $SFX

var rng = RandomNumberGenerator.new()
var is_cooling_down = false

####### Attack #######
func attack() -> void:
	if player == null || is_cooling_down:
		return
	
	if !player_is_in_range() || !player_is_in_sight():
		return
	
	emit_signal("start_attack")
	sfx.play()
	cooldown()
	yield(get_tree().create_timer(wind_up_time), "timeout")
	
	for _i in range(number_of_projectiles):
		spawn_projectile()
	
	yield(get_tree().create_timer(attack_duration - wind_up_time), "timeout")
	emit_signal("finish_attack")

func spawn_projectile() -> void:
	var direction = get_projectile_direction()
	var projectile = projectile_template.instance()
	projectile.translation = fire_point.global_transform.origin
	projectile.transform = projectile.transform.looking_at(player.translation, Vector3(0, 1, 0))
	get_tree().root.add_child(projectile)
	projectile.initialize(damage_per_projectile, projectile_speed, direction, projectile_lifetime)

func cooldown() -> void:
	is_cooling_down = true
	yield(get_tree().create_timer(attack_cooldown), "timeout")
	is_cooling_down = false

func get_projectile_direction() -> Vector3:
	var target_point = player.translation
	target_point.y += 1
	if projectile_spread <= 0:
		return (target_point - fire_point.global_transform.origin).normalized()
	
	rng.randomize()
	var offset_direction = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
	target_point += (offset_direction * rng.randf_range(0, projectile_spread))
	return (target_point - fire_point.global_transform.origin).normalized()

func player_is_in_range() -> bool:
	return (player.translation - get_parent().global_transform.origin).length() <= attack_range

func player_is_in_sight() -> bool:
	var space_state = get_world().direct_space_state
	var ray_result = space_state.intersect_ray(fire_point.global_transform.origin, player.translation, [get_parent()])
	if ray_result.empty():
		return false
	if ray_result.collider is PlayerController:
		return true
	return false

####### Utils #######
func set_player(p):
	player = p
