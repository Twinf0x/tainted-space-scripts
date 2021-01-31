class_name MenuController
extends Node

onready var title = $TitleSection
onready var more = $MoreSection

var level = preload("res://scenes/levels/Spaceship.tscn")

func _ready():
	self.remove_child(title)
	self.remove_child(more)
	show_title()

func show_title() -> void:
	if more.is_inside_tree():
		self.remove_child(more)
	self.add_child(title)

func show_more() -> void:
	if title.is_inside_tree():
		self.remove_child(title)
	self.add_child(more)

func start_the_game() -> void:
	get_tree().root.add_child(level.instance())
	get_tree().root.remove_child(self)


func leave_game() -> void:
	get_tree().quit()
