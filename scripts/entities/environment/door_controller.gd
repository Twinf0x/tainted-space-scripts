class_name DoorController
extends StaticBody

onready var animation_player = $AnimationPlayer
onready var sfx_player = $OpenSFX

var is_open = false

func open(other = null) -> void:
	if other != null && !(other is PlayerController):
		return
	
	if is_open:
		return
	
	animation_player.play("open")
	sfx_player.play()
	is_open = true

func close(other = null) -> void:
	if other != null && !(other is PlayerController):
		return
	
	if !is_open:
		return
	
	animation_player.play("close")
	is_open = false
