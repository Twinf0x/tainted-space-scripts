class_name WeaponsController
extends Node

export(NodePath) var weapon_sprite_path
export(NodePath) var crosshair_path

onready var fire_point = $"../FirePoint"
onready var camera = $"../Camera"
onready var animation_player = $"../AnimationPlayer"
onready var weapon_sprite = get_node(weapon_sprite_path)
onready var crosshair = get_node(crosshair_path)

var weapons
var current_weapon
var current_weapon_index = 0
var is_switching = false

####### Setup #######
func _ready():
	update_weapons()
	initialize_all_weapons()
	
	current_weapon_index = 0
	
	if !weapons.empty():
		current_weapon = weapons[current_weapon_index]
		apply_visuals_to_hud(current_weapon)

func update_weapons():
	weapons = []
	for weapon in get_children():
		remove_listeners(weapon)
		weapons.append(weapon)
		add_listeners(weapon)

func initialize_all_weapons():
	for weapon in weapons:
		weapon.initialize(camera, fire_point)

func remove_listeners(weapon):
	weapon.disconnect("weapon_firing", self, "on_weapon_firing")
	weapon.disconnect("weapon_empty", self, "on_weapon_empty")
	weapon.disconnect("weapon_equipped", self, "on_weapon_equipped")
	weapon.disconnect("weapon_unequipped", self, "on_weapon_unequipped")

func add_listeners(weapon):
	weapon.connect("weapon_firing", self, "on_weapon_firing")
	weapon.connect("weapon_empty", self, "on_weapon_empty")
	weapon.connect("weapon_equipped", self, "on_weapon_equipped")
	weapon.connect("weapon_unequipped", self, "on_weapon_unequipped")

func apply_visuals_to_hud(weapon):
	weapon_sprite.texture = current_weapon.weapon_texture
	weapon_sprite.vframes = current_weapon.vframes
	weapon_sprite.hframes = current_weapon.hframes

####### Utils #######
func is_current_weapon_index(index):
	return current_weapon_index == index

func is_current_weapon(weapon):
	return current_weapon == weapon

func has_weapon(weapon_name) -> bool:
	for weapon in weapons:
		if weapon.weapon_name == weapon_name:
			return true
	
	return false

func get_weapon_index(weapon_name) -> int:
	for weapon in weapons:
		if weapon.weapon_name == weapon_name:
			return weapons.find(weapon)
	return -1

func can_pick_up_ammo_for(weapon_name) -> bool:
	for weapon in weapons:
		if weapon.weapon_name == weapon_name && weapon.current_ammo < weapon.max_ammo:
			return true
	
	return false

func add_ammo(weapon_name, amount):
	for weapon in weapons:
		if weapon.weapon_name == weapon_name:
			weapon.add_ammo(amount)
			return

func current_ammo():
	if current_weapon != null:
		return current_weapon.current_ammo
	
	return 0

####### Input Handling #######
func shoot():
	if is_switching || current_weapon == null:
		return
	
	current_weapon.shoot()

####### Weapon Switching #######
func next_weapon():
	if is_switching:
		return
	start_weapon_switch((current_weapon_index + 1) % weapons.size())

func previous_weapon():
	if is_switching:
		return
	start_weapon_switch((current_weapon_index - 1) % weapons.size())

func start_weapon_switch(index):
	is_switching = true
	animation_player.play("hide_weapon")
	current_weapon_index = index
	
	if current_weapon != null:
		current_weapon.unequip()
	else:
		on_weapon_unequipped(null)

func finish_weapon_switch():
	current_weapon = weapons[current_weapon_index]
	is_switching = false

####### Weapon Events #######
func on_weapon_firing():
	animation_player.stop()
	animation_player.play("%s_firing" % current_weapon.name)

func on_weapon_empty():
	next_weapon()

func on_weapon_unequipped(weapon):
	current_weapon = weapons[current_weapon_index]
	weapon_sprite.texture = current_weapon.weapon_texture
	weapon_sprite.vframes = current_weapon.vframes
	weapon_sprite.hframes = current_weapon.hframes
	animation_player.play("show_weapon")
	crosshair.texture = current_weapon.crosshair_texture
	current_weapon.equip()

func on_weapon_equipped(weapon):
	if !is_current_weapon(weapon):
		return
	finish_weapon_switch()

####### Pick Up Weapon #######
func add_weapon(weapon_node):
	add_child(weapon_node)
	weapon_node.initialize(camera, fire_point)
	update_weapons()
	
	var weapon_index = get_weapon_index(weapon_node.weapon_name)
	start_weapon_switch(weapon_index)
