class_name Weapon
extends Spatial

export var weapon_name = "weapon"
# Time in seconds until a weapon can fire again after shooting
export var cooldown = 1.0
# Percentage of the screen height by which a bullet can diverge from the center
export var min_spread = 0.01
export var max_spread = 0.025
# A burst consists of X shots that get fired one after another..
export var shots_per_burst = 1
# ...with some time in between the shots
export var burst_delay = 0.05
# Some weapons fire several bullets with a single shot (e.g. shotguns)
export var bullets_per_shot = 1
# Values needed for the bullet's logic
export var damage_per_bullet = 0
export var bullet_speed = 0
# The bullet template contains logic and visuals
export(PackedScene) var bullet_template
export var bullet_lifetime = 10
export var max_ammo = -1
export var start_ammo = -1
# Animation stuff
export var equip_time = 0.5
export(Texture) var weapon_texture
export var vframes = 1
export var hframes = 1
# HUD Stuff
export(Texture) var crosshair_texture

signal weapon_firing
signal weapon_empty
signal weapon_unequipped(weapon)
signal weapon_equipped(weapon)

onready var max_focus_distance = bullet_lifetime * bullet_speed
onready var audio_source = $AudioStreamPlayer

var rng = RandomNumberGenerator.new()
var is_cooling_down = false
var camera
var current_ammo
var muzzle

####### Setup #######
func initialize(camera, muzzle):
	self.camera = camera
	self.muzzle = muzzle
	current_ammo = start_ammo

####### Shooting #######
func shoot():
	if is_cooling_down:
		return
	
	if current_ammo <= 0 && max_ammo > 0:
		emit_signal("weapon_empty")
		return
	
	current_ammo -= 1
	cooldown()
	emit_signal("weapon_firing")
	audio_source.play()
	for i in range(shots_per_burst):
		for j in range(bullets_per_shot):
			spawn_bullet()
		
		yield(get_tree().create_timer(burst_delay), "timeout")

func cooldown():
	is_cooling_down = true
	yield(get_tree().create_timer(cooldown), "timeout")
	is_cooling_down = false

func spawn_bullet():
	var direction = get_bullet_direction(get_aim_distance())
	var bullet = bullet_template.instance()
	bullet.translation = muzzle.global_transform.origin
	get_tree().root.add_child(bullet)
	bullet.initialize(damage_per_bullet, bullet_speed, direction, bullet_lifetime)

func get_aim_distance():
	var origin = get_viewport().size / 2
	var from = camera.project_ray_origin(origin)
	var to = from + camera.project_ray_normal(origin) * max_focus_distance
	var space_state = get_world().direct_space_state
	var ray_result = space_state.intersect_ray(from, to, [get_parent()])
	
	if !ray_result.empty():
		return ray_result.position.distance_to(global_transform.origin)
	else:
		return max_focus_distance

func get_bullet_direction(distance):
	rng.randomize()
	
	var origin = get_viewport().size / 2
	var spread = lerp(min_spread, max_spread, distance / max_focus_distance)
	var deviation = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized() * (get_viewport().size.y * rng.randf_range(0, spread))
	origin += deviation
	
	var from = camera.project_ray_origin(origin)
	var to = from + camera.project_ray_normal(origin) * max_focus_distance
	
	var space_state = get_world().direct_space_state
	var ray_result = space_state.intersect_ray(from, to, [get_parent()])
	if !ray_result.empty():
		return (ray_result.position - muzzle.global_transform.origin).normalized()
	
	var target_point = camera.global_transform.translated(Vector3(0, 0, -max_focus_distance)).origin
	return (target_point - muzzle.global_transform.origin).normalized()

####### (Un-)Equip #######
func equip():
	yield(get_tree().create_timer(equip_time), "timeout")
	emit_signal("weapon_equipped", self)

func unequip():
	yield(get_tree().create_timer(equip_time), "timeout")
	emit_signal("weapon_unequipped", self)

####### Ammo #######
func add_ammo(amount):
	current_ammo += amount
	if current_ammo > max_ammo:
		current_ammo = max_ammo
