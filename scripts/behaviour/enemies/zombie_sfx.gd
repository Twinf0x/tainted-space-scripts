class_name ZombieSFX
extends Spatial

onready var sfx = $SFX

func _ready():
	get_parent().connect("detected_player", self, "play")

func play():
	sfx.play()
