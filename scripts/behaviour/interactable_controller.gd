class_name InteractableController
extends Spatial

export(int, LAYERS_3D_PHYSICS) var interactable_layer
export(float) var interaction_range = 4.0
onready var camera = $"../Camera"

var focussed_interactable = null

func _physics_process(delta):
	var origin = get_viewport().size / 2
	var from = camera.project_ray_origin(origin)
	var to = from + camera.project_ray_normal(origin) * interaction_range
	var space_state = get_world().direct_space_state
	var ray_result = space_state.intersect_ray(from, to, [get_parent()], interactable_layer, false, true)
	
	if !ray_result.empty():
		if !(ray_result.collider is Interactable):
			return
		if focussed_interactable != ray_result.collider:
			if focussed_interactable != null:
				focussed_interactable.unfocus()
			focussed_interactable = ray_result.collider
			focussed_interactable.focus()
	elif focussed_interactable != null:
		focussed_interactable.unfocus()
		focussed_interactable = null
	
	if Input.is_action_just_pressed("interact") && focussed_interactable != null:
		focussed_interactable.trigger()
