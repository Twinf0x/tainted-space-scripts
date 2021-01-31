class_name LinkHandler
extends Node

func open(link) -> void:
	OS.shell_open(link)
