class_name PlaySFX
extends Spatial

export(NodePath) var sfx_path

onready var sfx = get_node(sfx_path)

func play():
	sfx.play()
