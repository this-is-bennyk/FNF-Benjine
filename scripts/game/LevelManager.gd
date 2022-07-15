extends "res://scripts/general/StateManager.gd"

export(Array, Resource) var state_stack = []
export(Array, Dictionary) var state_args = []
export(int) var difficulty = 2

onready var main = get_parent()

var story_mode_path = "res://scenes/shared/menus/default_menus/StoryModeMenu.tscn"
var freeplay_path = "res://scenes/shared/menus/default_menus/FreeplayMenu.tscn"
var prev_state_variables := {}

var pause_scene

var cur_state_idx = 0
var prev_state_idx = -1

var has_died_this_song = false
var is_freeplay = false

var level_infos = {}

func _ready():
	on_ready()

func on_ready():
	pause_scene = preload("res://scenes/shared/game/PauseState.tscn")
	
	var result = _load_level_infos()
	while result is GDScriptFunctionState:
		result = yield(result, "completed")
	
	call_deferred("advance_state_stack")

func advance_state_stack():
	if cur_state_idx < len(state_stack):
		var scene: PackedScene
		var scene_variables: Dictionary
		
		var cur_state = state_stack[cur_state_idx]
		
		if cur_state is SongData:
			var level_info_path = cur_state.level_info_paths[difficulty]
#			var level_info: LevelInfo = load(level_info_path)
			var level_info: LevelInfo = level_infos[level_info_path]
			var song_chart: SongChart = level_info.chart
			
			scene = level_info.level
			
			if state_args[cur_state_idx] != null && !state_args[cur_state_idx].empty():
				scene_variables = state_args[cur_state_idx]
				scene_variables["song_data"] = cur_state
				scene_variables["song_chart"] = song_chart
				scene_variables["level_info"] = level_info
				scene_variables["save_package"] = UserData.get_package_based_on_song_data(cur_state)
				scene_variables["save_name"] = cur_state.name
				scene_variables["save_difficulty"] = cur_state.difficulty_names[difficulty]
			else:
				scene_variables = {
					"song_data": cur_state,
					"song_chart": song_chart,
					"level_info": level_info,
					"save_package": UserData.get_package_based_on_song_data(cur_state),
					"save_name": cur_state.name,
					"save_difficulty": cur_state.difficulty_names[difficulty]
				}
		
			if prev_state_idx != cur_state_idx:
				has_died_this_song = false
		
		else: # Assumed to be a PackedState
			scene = cur_state
			scene_variables = state_args[cur_state_idx]
		
		switch_state(scene, scene_variables)
	else:
		quit_to_menu()

func go_to_next_state():
	prev_state_idx = cur_state_idx
	cur_state_idx += 1
	advance_state_stack()

func set_pause(paused):
	var pause_scene_instance
	
	if paused:
		pause_scene_instance = pause_scene.instance()
		add_child(pause_scene_instance)
	else:
		pause_scene_instance = get_child(get_child_count() - 1)
		remove_child(pause_scene_instance)
		pause_scene_instance.queue_free()
		Conductor.reset_time_at_last_update()
	
	get_tree().paused = paused

func restart():
	Conductor.stop_song()
	get_tree().paused = false
	
	prev_state_idx = cur_state_idx
	advance_state_stack()

func has_restarted():
	return prev_state_idx == cur_state_idx

func die(scene: PackedScene, scene_variables: Dictionary = {}):
	has_died_this_song = true
	switch_state(scene, scene_variables)

func in_last_state():
	return cur_state_idx == len(state_stack) - 1

func quit_to_menu():
	Conductor.stop_song()
	get_tree().paused = false
	
	if is_freeplay:
		main.switch_state(freeplay_path, prev_state_variables)
	else:
		main.switch_state(story_mode_path, prev_state_variables)

func _load_level_infos():
	var paths = []
	for state in state_stack:
		if state is SongData:
			paths.push_back(state.level_info_paths[difficulty])
	
	Loader.load_objects(paths)
	level_infos = yield(Loader, "loaded")
