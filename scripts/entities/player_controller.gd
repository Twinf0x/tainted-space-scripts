class_name PlayerController
extends KinematicBody

export var damage = 50
export var speed = 5
export var mouse_sensitivity = 0.5
export var min_pitch = -60
export var max_pitch = 60
export(NodePath) var camera_node
export(NodePath) var blood_border_path
export(NodePath) var pause_menu_parent_path
export(NodePath) var pause_menu_path
export(NodePath) var music_button_path
export(NodePath) var sfx_button_path
export(NodePath) var game_over_parent_path
export(NodePath) var game_over_path
export(NodePath) var victory_parent_path
export(NodePath) var victory_path
export(Texture) var checkmark
export(Texture) var cross
export var blood_border_hide_delay = 0.5
export var blood_border_hide_time = 1

onready var animation_player = $AnimationPlayer
onready var destructable = $Destructable
onready var weapons_controller = $WeaponsController
onready var music_controller = $MusicController
onready var camera = get_node(camera_node)
onready var blood_border = get_node(blood_border_path)
onready var pause_menu_parent = get_node(pause_menu_parent_path)
onready var pause_menu = get_node(pause_menu_path)
onready var music_button = get_node(music_button_path)
onready var sfx_button = get_node(sfx_button_path)
onready var game_over_parent = get_node(game_over_parent_path)
onready var game_over = get_node(game_over_path)
onready var victory_parent = get_node(victory_parent_path)
onready var victory = get_node(victory_path)

var blood_border_hide_timer: float = 0.0
var blood_border_min_visibility: float = 0.0
var modulate_color: Color = Color(1, 1, 1, 0)
var is_paused: bool = false

# Godot events
func _ready():
	get_node("/root/GameController").player = self
	close_pause_menu()
	hide_game_over()
	hide_victory()

func _input(event):
	if is_paused:
		return
		
	if event is InputEventMouseMotion:
		# directly apply rotation around the y-axis to the player
		rotation_degrees.y -= mouse_sensitivity * event.relative.x
		# clamp rotationaround the x-axis and apply to the camera
		var rotation = camera.rotation_degrees.x - (mouse_sensitivity * event.relative.y)
		rotation = clamp(rotation, min_pitch, max_pitch)
		camera.rotation_degrees.x = rotation

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if is_paused:
			close_pause_menu()
		else:
			open_pause_menu()
	update_blood_border(delta)

func _physics_process(delta):
	if is_paused:
		return
	
	# process movement input
	var direction = Vector3()
	if Input.is_action_pressed("move_forwards"):
		direction.z -= 1
	if Input.is_action_pressed("move_backwards"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	direction = direction.normalized()
	direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
	move_and_collide(direction * speed * delta)
	
	if direction.length() != 0.0:
		music_controller.start_footsteps()
	else:
		music_controller.stop_footsteps()
	
	# process shooting input
	if Input.is_action_pressed("shoot"):
		weapons_controller.shoot()
	
	# process weapon switching
	if Input.is_action_pressed("next_weapon"):
		weapons_controller.next_weapon()
	elif Input.is_action_pressed("previous_weapon"):
		weapons_controller.previous_weapon()

func initialize():
	destructable.current_health = destructable.max_health

# Implement wrapper for destructable
func take_damage(amount):
	destructable.take_damage(amount)
	update_blood_border_min()
	show_blood_border()
	if destructable.has_low_health():
		music_controller.start_heartbeat()
	else:
		music_controller.stop_heartbeat()

func heal_by(amount) -> void:
	destructable.heal_by(amount)
	update_blood_border_min()
	if destructable.has_low_health():
		music_controller.start_heartbeat()
	else:
		music_controller.stop_heartbeat()

func on_death() -> void:
	show_game_over()

# Implement wrapper for weapons controller
func has_weapon(weapon_name) -> bool:
	return weapons_controller.has_weapon(weapon_name)

func can_pick_up_ammo_for(weapon_name) -> bool:
	return weapons_controller.can_pick_up_ammo_for(weapon_name)

func add_ammo(weapon_name, amount):
	weapons_controller.add_ammo(weapon_name, amount)

# HUD
func show_blood_border() -> void:
	blood_border_hide_timer = blood_border_hide_delay
	var blood_visibility = 1.0 - (destructable.current_health / destructable.max_health)
	modulate_color = Color(1, 1, 1, blood_visibility)
	blood_border.modulate = modulate_color

func update_blood_border(delta) -> void:
	if modulate_color.a <= blood_border_min_visibility:
		modulate_color.a = blood_border_min_visibility
		blood_border.modulate = modulate_color
		return
	
	if blood_border_hide_timer > 0:
		blood_border_hide_timer -= delta
		return
	
	var visibility_delta = (delta / blood_border_hide_time) * (1.0 - blood_border_min_visibility)
	modulate_color.a -= visibility_delta
	blood_border.modulate = modulate_color

func update_blood_border_min() -> void:
	blood_border_min_visibility = (1.0 - (destructable.current_health / destructable.max_health)) / 3.0

# Pause menu
func open_pause_menu() -> void:
	is_paused = true
	get_tree().paused = true
	Engine.time_scale = 0.0
	pause_menu_parent.add_child(pause_menu)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_pause_menu() -> void:
	is_paused = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	pause_menu_parent.remove_child(pause_menu)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func toggle_music() -> void:
	var bus_id = AudioServer.get_bus_index("Music")
	var mute = !AudioServer.is_bus_mute(bus_id)
	AudioServer.set_bus_mute(bus_id, mute)
	
	if mute:
		music_button.icon = cross
	else:
		music_button.icon = checkmark

func toggle_sfx() -> void:
	var bus_id = AudioServer.get_bus_index("SFX")
	var mute = !AudioServer.is_bus_mute(bus_id)
	AudioServer.set_bus_mute(bus_id, mute)
	
	if mute:
		sfx_button.icon = cross
	else:
		sfx_button.icon = checkmark

func restart() -> void:
	get_tree().change_scene("res://scenes/levels/MainMenu.tscn")
	get_tree().root.remove_child(get_parent())

func leave_game() -> void:
	get_tree().quit()

# Game Over
func show_game_over() -> void:
	is_paused = true
	get_tree().paused = true
	Engine.time_scale = 0.0
	game_over_parent.add_child(game_over)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_game_over() -> void:
	is_paused = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	game_over_parent.remove_child(game_over)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Victory
func show_victory() -> void:
	is_paused = true
	get_tree().paused = true
	Engine.time_scale = 0.0
	music_controller.stop_boss()
	victory_parent.add_child(victory)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_victory() -> void:
	is_paused = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	victory_parent.remove_child(victory)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
