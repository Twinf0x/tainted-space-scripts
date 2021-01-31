class_name EncounterController
extends Node

export(bool) var play_boss_music = false
export(Array, NodePath) var wave_controllers

var wave_controller_nodes := Array()
var next_wave_index: int = 0
var cleared_wave_count: int = 0
var encounter_has_started = false

onready var music = get_node("/root/GameController").player.music_controller

signal begin_encounter
signal finished_encounter

func _ready():
	for controller_path in wave_controllers:
		var controller = get_node(controller_path)
		controller.connect("next_wave", self, "next_wave")
		controller.connect("cleared_wave", self, "cleared_wave")
		wave_controller_nodes.append(controller)

func start_encounter_on_kill():
	if encounter_has_started:
		return
	
	encounter_has_started = true
	music.start_battle()
	next_wave()
	emit_signal("begin_encounter")

func start_encounter_on_area_enter(other):
	if !(other is PlayerController) || encounter_has_started:
		return
	
	encounter_has_started = true
	if play_boss_music:
		music.start_boss()
	else:
		music.start_battle()
	next_wave()
	emit_signal("begin_encounter")

func next_wave():
	if next_wave_index >= wave_controller_nodes.size():
		return
	
	var controller = wave_controller_nodes[next_wave_index]
	controller.start_wave()
	next_wave_index += 1

func cleared_wave():
	cleared_wave_count += 1
	if cleared_wave_count >= wave_controllers.size():
		finish_encounter()

func finish_encounter():
	if play_boss_music:
		music.stop_boss()
	else:
		music.stop_battle()
		music.finish_battle()
	emit_signal("finished_encounter")
