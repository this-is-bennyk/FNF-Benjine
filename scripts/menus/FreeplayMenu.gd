extends Node

const MAIN_MENU = preload("res://scenes/shared/menus/default_menus/MainMenu.tscn")
const LEVEL_MANAGER = preload("res://scenes/shared/game/LevelManager.tscn")

export(NodePath) var song_select_menu_path
export(NodePath) var inst_player_path
export(NodePath) var tween_path
export(NodePath) var bg_path

export(NodePath) var score_fg_path
export(NodePath) var score_bg_path
export(NodePath) var difficulty_name_path

export(NodePath) var song_speed_indicator_path
export(NodePath) var song_speed_changer_path

export(NodePath) var botplay_button_path

export(NodePath) var cancel_sound_path

onready var song_selection_menu = get_node(song_select_menu_path)
onready var inst_player = get_node(inst_player_path)
onready var tween = get_node(tween_path)
onready var bg = get_node(bg_path)

onready var score_fg = get_node(score_fg_path)
onready var score_bg = get_node(score_bg_path)
onready var difficulty_name = get_node(difficulty_name_path)

onready var song_speed_indicator = get_node(song_speed_indicator_path)
onready var song_speed_changer = get_node(song_speed_changer_path)

onready var botplay_button = get_node(botplay_button_path)

onready var cancel_sound = get_node(cancel_sound_path)

var freeplay_list = []
var prev_menu_path = ""
var immediate_load = true
var song_idx = 0
var difficulty_idx = 1

var cached_instrumentals = {}

var cur_bg_color
var cur_outline_color

var song_score = 0
var song_lerp_score = 0

func _ready():
	on_ready()

func _process(delta):
	on_update(delta)

func _input(event):
	on_input(event)

# Pre: If no freeplay list specified, at least the FNF freeplay list exists
func on_ready():
	if freeplay_list.empty():
		freeplay_list = UserData.get_entire_basic_mod_freeplay_list()
	
	# CORNER: the first song has only 1 difficulty
	var cur_num_difficulties = len(freeplay_list[song_idx].difficulty_names)
	if cur_num_difficulties < 2:
		difficulty_idx = 0
	
	var song_select_menu_ref = get_node(song_select_menu_path)
	
	song_select_menu_ref.options = []
	
	for song_data in freeplay_list:
		song_select_menu_ref.options.append(song_data.name)
	
	song_select_menu_ref.on_ready(false)
	
	for idx in song_select_menu_ref.options_container.get_child_count():
		var icon = AnimatedSprite.new()
		var option = song_select_menu_ref.options_container.get_child(idx)
		
		icon.frames = freeplay_list[idx].icons
		icon.frame = freeplay_list[idx].icon_index
		
		option.add_child(icon)
		
		icon.position.x = option.rect_size.x + 75 + 20
		icon.position.y = 27.5
	
	song_select_menu_ref.change_option_to(song_idx)
	
	change_song(get_node(inst_player_path))
	
	get_node(bg_path).material.set_shader_param("bg_color", cur_bg_color)
	get_node(bg_path).material.set_shader_param("outline_color", cur_outline_color)
	
	change_song_stats()
	song_lerp_score = song_score
	
	get_node(song_speed_indicator_path).text = "Song Speed: " + str(Conductor.pitch_scale)
	get_node(song_speed_changer_path).value = Conductor.pitch_scale
	
	get_node(botplay_button_path).pressed = Debug.botplay
	
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func on_update(delta):
	if !inst_player.playing:
		inst_player.play()
	
	if db2linear(inst_player.volume_db) < 0.7:
		inst_player.volume_db = linear2db(db2linear(inst_player.volume_db) + (0.5 * delta))
	
	song_lerp_score = lerp(song_lerp_score, song_score, GodotX.get_haxeflixel_lerp(0.2))
	score_fg.text = String(round(song_lerp_score))
	score_bg.text = score_fg.text
	
	update_bg_material()

func on_input(event):
	if GodotX.xor(event.is_action_pressed("ui_left"), event.is_action_pressed("ui_right")):
		var increment = -1 if event.is_action_pressed("ui_left") else 1
		
		difficulty_idx = wrapi(difficulty_idx + increment, 0, len(freeplay_list[song_idx].difficulty_names))
		change_song_stats()
	
	elif event.is_action_released("ui_cancel"):
		_disable_input()
		_stop_music()
		
		Conductor.set_pitch_scale()
		Debug.botplay = false
		
		cancel_sound.play()
		
		TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
		TransitionSystem.connect("transition_finished", self, "_switch_to_main_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	
	else:
		song_selection_menu.on_input(event)

func update_bg_material():
	if bg.material.get_shader_param("bg_color") != cur_bg_color:
		var lerp_val = GodotX.get_haxeflixel_lerp(0.08)
		
		bg.material.set_shader_param("bg_color", lerp(bg.material.get_shader_param("bg_color"), cur_bg_color, lerp_val))
		bg.material.set_shader_param("outline_color", lerp(bg.material.get_shader_param("outline_color"), cur_outline_color, lerp_val))

func change_song(inst_player_ref = null):
	var i_player = inst_player_ref if inst_player_ref else inst_player
	_check_for_instrumental(song_idx)
	
	i_player.volume_db = linear2db(0)
	i_player.stream = cached_instrumentals[song_idx]
	i_player.play()
	
	cur_bg_color = freeplay_list[song_idx].freeplay_bg_color
	cur_outline_color = freeplay_list[song_idx].freeplay_outline_color

func change_song_stats():
	var cur_song_data = freeplay_list[song_idx]
	var diff_name_ref = difficulty_name if difficulty_name else get_node(difficulty_name_path)
	var cur_diff_name = cur_song_data.difficulty_names[difficulty_idx]
	
	song_score = UserData.get_song_score(cur_song_data.name, cur_diff_name, UserData.get_package_based_on_song_data(cur_song_data))
	diff_name_ref.text = "< " + cur_diff_name + " >"

func _check_for_instrumental(idx):
	if !cached_instrumentals.has(idx):
		cached_instrumentals[idx] = load(freeplay_list[idx].inst_preview_path)

func _on_option_changed(option_idx, _option):
	var prev_num_difficulties = len(freeplay_list[song_idx].difficulty_names)
	
	song_idx = option_idx
	
	var cur_num_difficulties = len(freeplay_list[song_idx].difficulty_names)
	
	if cur_num_difficulties < prev_num_difficulties:
		difficulty_idx = clamp(difficulty_idx, 0, cur_num_difficulties - 1)
	elif cur_num_difficulties > prev_num_difficulties:
		difficulty_idx = int(cur_num_difficulties / 2.0)
	# Otherwise the index stays the same (since the player prolly wants the same difficulty)
	
	change_song()
	change_song_stats()

func _on_option_selected(_option_idx, _option):
	_disable_input()
	
	tween.interpolate_property(inst_player, "volume_db", linear2db(0.7), linear2db(0.005), 0.7)
	tween.start()
	
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
	TransitionSystem.connect("transition_finished", self, "_stop_music", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	TransitionSystem.connect("transition_finished", self, "_switch_to_level", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _disable_input():
	set_process(false)
	set_process_input(false)
	
	song_selection_menu.disable_input()
	song_selection_menu.disconnect("option_changed", self, "_on_option_changed")
	
	song_speed_changer.editable = false
	
	botplay_button.disabled = true

func _stop_music(_trans_name = ""):
	inst_player.stop()

func _switch_to_level(_trans_name):
	var song_data: SongData = freeplay_list[song_idx]
	
	var level_manager_args = {
		"state_stack": [
			song_data
		],
		"state_args": [
			{}
		],
		"difficulty": difficulty_idx,
		"is_freeplay": true,
		"prev_state_variables": {
			"freeplay_list": freeplay_list,
			"prev_menu_path": prev_menu_path,
			"immediate_load": immediate_load,
			"song_idx": song_idx,
			"difficulty_idx": difficulty_idx
		}
	}
	
	get_parent().switch_state(LEVEL_MANAGER, level_manager_args)

func _switch_to_main_menu(_trans_name):
	if prev_menu_path.empty():
		get_parent().switch_state(MAIN_MENU)
		return
	
	if prev_menu_path == "QUIT":
		get_tree().quit()
	elif immediate_load:
		get_parent().switch_state(load(prev_menu_path))
	else:
		get_parent().switch_state(prev_menu_path)

func _on_song_speed_changed(value: float):
	Conductor.set_pitch_scale(value)
	song_speed_indicator.text = "Song Speed: " + str(value)

func _on_botplay_toggled(pressed: bool):
	Debug.botplay = pressed
