extends Node

const DEFAULT_LOADING_SCREEN = preload("res://scenes/shared/menus/LoadingScreen.tscn")

signal loaded(assets)

var loader: ResourceInteractiveLoader
var loading_screen

func load_objects(object_paths: Array, loading_screen_path: String = ""):
	_get_loading_screen(loading_screen_path)

	# Fade in once we have a loading screen
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)
	yield(TransitionSystem, "transition_finished")

	# Load all assets
	var assets = {}
	for path in object_paths:
		var asset = _load_object(path)
		
		while asset is GDScriptFunctionState:
			asset = yield(asset, "completed")
		
		assets[path] = asset

	# Fade out the loading screen
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
	yield(TransitionSystem, "transition_finished")
	
	_remove_loading_screen()
	
	emit_signal("loaded", assets)

func _load_object(object_path: String):
	# Load the asset
	var asset = _do_load(object_path)
	while asset is GDScriptFunctionState:
		asset = yield(asset, "completed")

	return asset

func _get_loading_screen(loading_screen_path: String = ""):
	if loading_screen_path.empty() || !ResourceLoader.exists(loading_screen_path):
		loading_screen = DEFAULT_LOADING_SCREEN.instance()
	else:
		loading_screen = load(loading_screen_path).instance()
	add_child(loading_screen)

func _remove_loading_screen():
	remove_child(loading_screen)
	loading_screen.queue_free()

func _do_load(path: String):
	loader = ResourceLoader.load_interactive(path)
	
	for i in loader.get_stage_count():
		var err = loader.poll()
		if !(err == OK || err == ERR_FILE_EOF):
			push_error("Exit during load! File not loaded: " + path + " (error code " + str(err) + ")")
			return null
		
		loading_screen.update_progress(float(i + 1) / float(loader.get_stage_count()))
		yield(get_tree().create_timer(0.02), "timeout")
	
	# Get the resource and clear the loader (to avoid loading the same resource twice)
	var result = loader.get_resource()
	loader = null
	
	return result
