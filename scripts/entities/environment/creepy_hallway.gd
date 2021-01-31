class_name CreepyHallway
extends Spatial

onready var sfx = $HallwaySFX
onready var lights = $Lights
onready var doors = $Doors
onready var encounter = $EncounterController

var is_triggered: bool = false

func trigger(other = null) -> void:
	if is_triggered:
		return
	if other != null && !(other is PlayerController):
		return
	
	is_triggered = true
	lights.turn_off()
	sfx.play()
	yield(get_tree().create_timer(2.0), "timeout")
	doors.open()
	yield(get_tree().create_timer(1.0), "timeout")
	encounter.start_encounter_on_kill()
