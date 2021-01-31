class_name AmmoDisplay
extends Label

onready var player = get_node("/root/GameController").player

func _process(delta):
	if player == null:
		player = get_node("/root/GameController").player
		return
		
	if player.weapons_controller.current_ammo() >= 0:
		text = str(player.weapons_controller.current_ammo())
	else:
		text = "endless"
