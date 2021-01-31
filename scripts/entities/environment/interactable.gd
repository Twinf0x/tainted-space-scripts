class_name Interactable
extends Area

export var is_active: bool = true

onready var hint = $Hint

signal interaction

func trigger() -> void:
	if !is_active:
		return
	
	emit_signal("interaction")

func focus() -> void:
	hint.visible = true

func unfocus() -> void:
	hint.visible = false

func activate() -> void:
	is_active = true

func deactivate() -> void:
	is_active = false
