extends Node

func switch_state(scene, scene_variables: Dictionary = {}):
	clear_current_state()
	
	var new_state
	
	if scene is PackedScene:
		new_state = scene.instance()
	else: # Assumed to be a String
		Loader.load_objects([scene])
		var scene_dict = yield(Loader, "loaded")
		new_state = scene_dict[scene].instance()
	
	for variable in scene_variables:
		new_state.set(variable, scene_variables[variable])
	
	add_child(new_state)

func clear_current_state():
	for child in get_children():
		remove_child(child)
		child.queue_free()
