extends Node

const MAIN_MENU = preload("res://scenes/shared/menus/default_menus/MainMenu.tscn")
const FREAKY_MENU = preload("res://assets/music/freakyMenu.ogg")

const NO_WEEK_LOGO = preload("res://assets/graphics/menus/story_mode/no_week.png")
const NO_WEEK_NAME = "Week ??"

export(NodePath) var week_select_menu_path

onready var week_select_menu = get_node(week_select_menu_path)
onready var confirm_sound = $Confirm_Sound
onready var cancel_sound = $Cancel_Sound

onready var week_name_display = $Week_Name
onready var week_score_display = $Week_Score
onready var week_tracklist_display = $Tracklist

onready var week_difficulty_display = $Cur_Difficulty
onready var week_difficulty_tween = $Cur_Difficulty/Tween
onready var prev_difficulty_btn = $Prev_Difficulty
onready var next_difficulty_btn = $Next_Difficulty

# TODO: softcode this
onready var player = $BG/ClipRect/Characters/BF_StoryMode
onready var metronome = $BG/ClipRect/Characters/GF_StoryMode
onready var opponent_list = $BG/ClipRect/Characters/Opponents

var week_idx = 0
var difficulty_idx = 1

var level_manager_paths = []
var week_names = []
var week_difficulties = []
var week_scores = []
var week_tracklists = []
var week_opponents = []

var cur_week_score = 0
var week_lerp_score = 0

func _ready():
	var weeks = UserData.get_entire_basic_mod_weeks_list()
	
	# CORNER: the first song has only 1 difficulty
	var cur_num_difficulties = len(weeks[0].week_difficulties.animations)
	if cur_num_difficulties < 2:
		difficulty_idx = 0
	
	level_manager_paths = []
	week_select_menu.options = []
	
	for week in weeks:
		# ----------------------------------
		# Necessary required info (can't have placeholders)
		# ----------------------------------
		# 1) Get this week's level manager (a scene that move thru songs/cutscenes/etc. in a sequence)
		level_manager_paths.append(week.level_manager_path)
		
		# Add this week's difficulties
		week_difficulties.append(week.week_difficulties)
		
		# 2) Get this week's list of tracks and its scores at each difficulty
		var tracklist = PoolStringArray()
		var scores = []
		
		# Clear the array with the correct number of scores
		for diff_idx in len(week.week_difficulties.animations):
			scores.append(0)
		
		for song_data in week.song_datas:
			var package = UserData.get_package_based_on_song_data(song_data)
			
			tracklist.append(song_data.name)
			
			# Add its score from each difficulty to the total scores of each difficulty of this week
			for diff_idx in len(week.week_difficulties.animations):
				scores[diff_idx] += UserData.get_song_score(song_data.name, song_data.difficulty_names[diff_idx], package)
		
		week_tracklists.append(tracklist)
		week_scores.append(scores)
		
		# ----------------------------------
		# Less-necessary required info (can have placeholders)
		# ----------------------------------
		if week.has("week_logo"):
			week_select_menu.options.append(week.week_logo)
		else:
			week_select_menu.options.append(NO_WEEK_LOGO)
		
		if week.has("week_name"):
			week_names.append(week.week_name)
		else:
			week_names.append(NO_WEEK_NAME)
		
		# ----------------------------------
		# Optional info
		# ----------------------------------
		# Add this week's characters
		if week.has("story_opponent_path"):
			var week_opp = load(week.story_opponent_path).instance()
			
			week_opp.hide()
			opponent_list.add_child(week_opp)
			
			week_opponents.append(week_opp)
		else:
			week_opponents.append(null)
	
	week_select_menu.on_ready(false)
	
	change_week_info()
	
	if !Conductor.playing || Conductor.stream != FREAKY_MENU:
		Conductor.volume_db = linear2db(0.8)
		Conductor.play_music(FREAKY_MENU, 102)
	
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func _process(delta):
	week_lerp_score = lerp(week_lerp_score, cur_week_score, GodotX.get_haxeflixel_lerp(0.5))
	week_score_display.text = "Week Score: " + String(round(week_lerp_score))

func _input(event):
	if GodotX.xor(event.is_action_pressed("ui_left"), event.is_action_pressed("ui_right")):
		var increment = -1 if event.is_action_pressed("ui_left") else 1
		
		difficulty_idx = wrapi(difficulty_idx + increment, 0, len(week_difficulty_display.frames.animations))
		
		change_week_info()
		_tween_difficulty()
		
		if event.is_action_pressed("ui_left"):
			prev_difficulty_btn.play("arrow push left")
		else:
			next_difficulty_btn.play("arrow push right")
		
	elif GodotX.xor(event.is_action_released("ui_left"), event.is_action_released("ui_right")):
		if event.is_action_released("ui_left"):
			prev_difficulty_btn.play("arrow left")
		else:
			next_difficulty_btn.play("arrow right")
		
	elif event.is_action_released("ui_cancel"):
		_disable_input()
		
		cancel_sound.play()
		
		TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
		TransitionSystem.connect("transition_finished", self, "_switch_to_main_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
	else:
		week_select_menu.on_input(event)

func change_week_info():
	week_name_display.text = week_names[week_idx]
	week_tracklist_display.text = "Tracks:\n\n" + week_tracklists[week_idx].join("\n")
	cur_week_score = week_scores[week_idx][difficulty_idx]
	week_difficulty_display.frames = week_difficulties[week_idx]
	week_difficulty_display.play(str(difficulty_idx))

func _tween_difficulty():
	week_difficulty_tween.stop_all()
	week_difficulty_tween.interpolate_property(week_difficulty_display, "offset:y", -15, 0, 0.07)
	week_difficulty_tween.interpolate_property(week_difficulty_display, "modulate:a", 0, 1, 0.07)
	week_difficulty_tween.start()

func _on_option_changed(option_idx, _option):
	var prev_difficulties = week_difficulty_display.frames
	var prev_num_difficulties = len(week_difficulty_display.frames.animations)
	
	if week_opponents[week_idx]:
		week_opponents[week_idx].hide()
	
	week_idx = option_idx
	change_week_info()
	
	var cur_difficulties = week_difficulty_display.frames
	var cur_num_difficulties = len(week_difficulty_display.frames.animations)
	
	if cur_difficulties != prev_difficulties:
		_tween_difficulty()
	
	if cur_num_difficulties < prev_num_difficulties:
		difficulty_idx = clamp(difficulty_idx, 0, cur_num_difficulties - 1)
	elif cur_num_difficulties > prev_num_difficulties:
		difficulty_idx = int(cur_num_difficulties / 2.0)
	# Otherwise the index stays the same (since the player prolly wants the same difficulty)
	
	if week_opponents[week_idx]:
		week_opponents[week_idx].show()

func _on_option_selected(_option_idx, _option):
	_disable_input()
	
	Conductor.stop_song()
	week_select_menu.options_container.get_child(week_idx).get_node("AnimationPlayer").play("Flashing")
	
	# TODO: Softcode this stuff for more customizability
	player.play_anim("Hey", 1.5)
	metronome.play_anim("Cheer", 1.5)
#	if week_opponents[week_idx]:
#		week_opponents[week_idx].play_anim("Idle", 1.5)
	
	confirm_sound.play()
	
	var timer = get_tree().create_timer(1)
	
	timer.connect("timeout", TransitionSystem, "play_transition", [TransitionSystem.Transitions.BASIC_FADE_OUT], CONNECT_DEFERRED | CONNECT_ONESHOT)
	timer.connect("timeout", TransitionSystem, "connect", ["transition_finished", self, "_switch_to_level", [], CONNECT_DEFERRED | CONNECT_ONESHOT], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _disable_input():
	set_process(false)
	set_process_input(false)
	
	week_select_menu.disable_input()
	week_select_menu.disconnect("option_changed", self, "_on_option_changed")

func _switch_to_level(_trans_name):
#	get_parent().switch_state(load(level_manager_paths[week_idx]), { "difficulty": difficulty_idx })
	get_parent().switch_state(level_manager_paths[week_idx], { "difficulty": difficulty_idx })

func _switch_to_main_menu(_trans_name):
	get_parent().switch_state(MAIN_MENU)
