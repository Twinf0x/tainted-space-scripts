class_name Destructable
extends Node

export var max_health = 100.0

var current_health = 0.0

onready var hurt_sfx = $HurtSFX

func _ready():
	current_health = max_health

func take_damage(amount):
	current_health -= amount
	if hurt_sfx != null:
		hurt_sfx.play_random_track()
	if current_health <= 0:
		on_death()

func heal():
	current_health = max_health

func heal_by(amount):
	current_health += amount
	if current_health > max_health:
		current_health = max_health

func on_death():
	if get_parent().has_method("on_death"):
		get_parent().on_death()

func has_full_health() -> bool:
	return current_health == max_health

func has_low_health() -> bool:
	return current_health <= 0.25 * max_health
