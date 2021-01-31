class_name SkullMovement
extends Node

export var speed = 7
export var min_height = 0.5
export var max_height = 2
export var update_target_after_min = 2
export var update_target_after_max = 5
export var preferred_distance = 13
export(Curve) var fall_curve
export var fall_time = 1.0

onready var player = get_node("/root/GameController").player

var player_offset: Vector3
var y_offset: Vector3
var target_point: Vector3
var rng = RandomNumberGenerator.new()
var should_update_target = true

func _ready() -> void:
	rng.randomize()
	var x = rng.randf_range(-1, 1)
	var z = rng.randf_range(-0.8, -0.5)
	var temp_offset = Vector3(x, 0, z).normalized() * preferred_distance
	player_offset = temp_offset + Vector3(0, rng.randf_range(min_height, max_height), 0)
	y_offset = Vector3(0, player_offset.y, 0)
	get_parent().connect("just_died", self, "fall_down")

func move(delta) -> bool:
	if player == null:
		return false
	
	# Rotate towards the player
	var player_direction = (player.translation - get_parent().translation).normalized()
	get_parent().transform = get_parent().transform.looking_at((player.global_transform.origin + y_offset), Vector3.UP)
	
	# Move to the player's position with the previously calculated offset
	if should_update_target:
		update_target()
		
	if get_parent().translation.distance_to(target_point) <= 0.05:
		return true
	var target_direction = (target_point - get_parent().translation).normalized()
	get_parent().move_and_collide(target_direction * speed * delta)
	return true

func update_target():
	target_point = player.global_transform.translated(player_offset).origin
	should_update_target = false
	var timer = rng.randf_range(update_target_after_min, update_target_after_max)
	yield(get_tree().create_timer(timer), "timeout")
	should_update_target = true

func fall_down():
	var initial_height = y_offset.y
	var fall_timer = 0
	while fall_timer < fall_time:
		fall_timer += get_process_delta_time()
		get_parent().translation.y = fall_curve.interpolate(fall_timer / fall_time) * initial_height
		yield(get_tree(), "idle_frame")
	
	get_parent().translation.y = 0
