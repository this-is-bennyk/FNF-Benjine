extends Node

# The following two values are extremely confusing in the Funkin' source, so lemme explain:

# HEALTH_PENALTY_OVERTAP: for when you tap on an empty space rather than a note.
#	- This could be between notes or in the stretches of time between player sections (no ghost tapping).
#	- Does not apply if you are already holding down the direction from a previous note.
#	- The vocals mute and the record scratch plays when applying an overtap penalty.
#	- Also BF gets stunned for 5 seconds

# HEALTH_PENALTY_MISS: for when the note has passed beyond the safe zone of its strum time.
#	- Also applies when missing the sustained part of a sustained note.
#	- The vocals mute when applying a miss penalty.

const MAX_HEALTH = 2
const HEALTH_BOOST = 0.023
const HEALTH_PENALTY_OVERTAP = -0.04
const HEALTH_PENALTY_MISS = -0.0475
const HEALTH_PENALTY_KE_BAD = -0.03
const HEALTH_PENALTY_KE_SHIT = -0.06

const COMBO_NUM_INIT_SCALE = 0.425
const COMBO_NUM_FINAL_SCALE = 0.375

const SCORE_NUM_INIT_SCALE = 0.3 * (0.425 / 0.375)
const SCORE_NUM_FINAL_SCALE = 0.3

const DEFAULT_DEATH_SCENE = preload("res://scenes/shared/game/game_over/GameOver.tscn")

const GameEventList       = preload("res://scripts/game/events/GameEventList.gd")
const RepeatEventList     = preload("res://scripts/game/events/RepeatingGameEventList.gd")
const RandRepeatEventList = preload("res://scripts/game/events/RandRepeatGameEventList.gd")

enum Ratings { SICK, GOOD, BAD, SHIT }

export(Dictionary) var performers = {
	player = "bf",
	metronome = "gf",
	opponent = ""
}

export(Dictionary) var character_paths = {
	bf = NodePath(),
	gf = NodePath()
}

export(Dictionary) var step_zone_paths = {
	player = NodePath(),
	opponent = NodePath()
}

export(NodePath) var hud_path
export(NodePath) var default_pos_path = NodePath("HUDPackage2D/Default_Pos")

onready var lvl_manager = get_parent()

# ---------- Characters ----------

# GitHub issue #48038: Exported arrays / dictionaries are shared
onready var _performers = performers.duplicate(true)

var characters = {
	bf = null,
	gf = null
}

# ---------- HUD ----------
# (Includes step zone and countdown voices)

onready var hud = get_node(hud_path)
onready var default_position = get_node(default_pos_path)

var step_zones = {
	player = null,
	opponent = null
}

var countdown_voices = []

# ---------- Songs + Notes ----------

var popup_combo: PackedScene

var miss_sounds = []

var song_data: SongData
var song_chart: SongChart
var level_info: LevelInfo

# ---------- Events ----------

var onetime_events = GameEventList.new()
var repeating_events = RepeatEventList.new()
var rand_repeat_events = RandRepeatEventList.new()
var camera_pan_events = GameEventList.new()

# ---------- Stats ----------

var health = 1 # Range: 0 - 2
var combo = 0 # Shits end combo, missing sustains doesn't
var score = 0
var total_possible_score = 0 # The score if you hit all sicks
var notes_hit = 0
var notes_missed = 0
var total_hittable_notes = 0
var dying = false
var can_pause = false
var botted = false

var save_package: String
var save_name: String
var save_difficulty: String

# ---------- Level Generation ----------

func _ready():
#	set_video_driver_stuff()
	on_ready()

# In inherited levels, any onready vars must be changed either here or when 
# the levels needs to change them
func on_ready():
	set_process(false)
	set_process_input(false)
	set_preload_variables()
	set_immediate_mandatory_connections()
	
	# This fixes all stutters caused by loading for some goddamn reason idfk why
	for _i in range(3):
		yield(get_tree(), "idle_frame")
	
	handle_prev_transition()
	
	call_deferred("start_level_part_1")

# For turning on / off certain things depending on the video driver
#func set_video_driver_stuff():
#	pass

func set_preload_variables():
	countdown_voices = [
		preload("res://assets/sounds/introGo.ogg"),
		preload("res://assets/sounds/intro1.ogg"),
		preload("res://assets/sounds/intro2.ogg"),
		preload("res://assets/sounds/intro3.ogg")
	]
	
	popup_combo = preload("res://scenes/shared/game/PopupCombo.tscn")
	
	miss_sounds = [
		preload("res://assets/sounds/missnote1.ogg"),
		preload("res://assets/sounds/missnote2.ogg"),
		preload("res://assets/sounds/missnote3.ogg")
	]

func set_immediate_mandatory_connections():
	Debug.connect("botplay_changed", self, "_on_botplay_changed")

func handle_prev_transition():
	match TransitionSystem.anim_player.assigned_animation:
		"Screen_Cap_Out":
			TransitionSystem.play_transition(TransitionSystem.Transitions.SCREEN_CAP_IN)
		_: # Anything else (Basic fade out / unhandled transition)
			TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func start_level_part_1():
	do_general_level_prep()
	
	if lvl_manager.has_died_this_song:
		start_level_part_2()
	else:
		if lvl_manager.is_freeplay:
			do_pre_level_freeplay_event()
		else:
			do_pre_level_story_event()
	
func start_level_part_2():
	Conductor.play_level_song_with_countdown(song_chart, level_info)
	
	can_pause = true
	set_process(true)
	set_process_input(true)
	
	Conductor.connect("quarter_hit", self, "do_countdown", [], CONNECT_ONESHOT)
	Conductor.connect("quarter_hit", self, "connect_end_of_song_signal", [], CONNECT_ONESHOT)

func end_level_part_1():
	Conductor.stop_song()
	
	if lvl_manager.is_freeplay:
		do_post_level_freeplay_event()
	else:
		do_post_level_story_event()

func end_level_part_2(_trans_name = ""):
	do_level_cleanup()
	
	if !botted && score > 0 && score > UserData.get_song_score(save_name, save_difficulty, save_package):
		UserData.set_song_score(save_name, save_difficulty, score, save_package)
	
	lvl_manager.go_to_next_state()

# ------------------------------
# do_pre_level_story_event
# Desc: Does an event before the start of the level (ex. a textbox, a cutscene, etc.).
# ------------------------------
# It MUST call start_level_part_2() by EITHER calling it directly (as seen below)
# or with a connection from a signal. DO NOT USE YIELD STATEMENTS, AS THEY ARE UNRELIABLE WITH SWITCHING STATES.
# Ex. of above:
# cutscene_player.connect("on_animation_finished", self, "_cutscene_finished", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
# func _cutscene_finished(anim_name):
# 	start_level_part_2()
# ------------------------------
func do_pre_level_story_event():
	start_level_part_2()

func do_pre_level_freeplay_event():
	start_level_part_2()

func initialize_lanes():
	for step_zone_name in step_zone_paths.keys():
		step_zones[step_zone_name] = get_node(step_zone_paths[step_zone_name]).get_children()
	
	for step_zone_name in step_zones.keys():
		var lanes = step_zones[step_zone_name]
		
		for lane_idx in len(lanes):
			var lane = lanes[lane_idx]
			
			lane.lvl = self
			lane.initialize(song_chart.lanes[step_zone_name][lane_idx])
	
	_on_botplay_changed()

func _on_botplay_changed():
	if Debug.botplay:
		for lane in step_zones.player:
			lane.lane_type = Lane.Type.BOTPLAY
		botted = true
		hud.update_score(score, 0, "--", -1)
	else:
		for lane in step_zones.player:
			lane.lane_type = Lane.Type.PLAYER
		if score > 0:
			hud.update_score(score, notes_missed, get_rating(get_average_accuracy()), get_display_average_accuracy())
		else:
			hud.update_score(score, 0, "--", -1)

func initialize_characters():
	for character_name in character_paths:
		characters[character_name] = get_node_or_null(character_paths[character_name])

func do_level_specific_prep():
	pass

func do_general_level_prep():
	initialize_lanes()
	initialize_characters()
	initialize_events()
	initialize_camera()
	
	# Initialize variables changed by this level
	do_level_specific_prep()
	
	# Initialize things that need to be initialized first
	# TODO: Unhardcode this shit
#	Conductor.volume_db = linear2db(0.6)
	Conductor.volume_db = 0
#	Conductor.vocals.volume_db = 0
	Conductor.vocals.volume_db = 0
	
	# Initialize variables constant for all levels
	dying = false
	
	update_score(0, true)
	hud.update_score(score, 0, "--", -1)
	
	switch_icons("player", "player")
	switch_icons("opponent", "opponent")
	
	update_health(1, true)

func initialize_camera():
	var first_char = level_info.camera_pan_events.list[0].func_ref_args[0] if level_info.camera_pan_events && !level_info.camera_pan_events.list.empty() else null
	set_cam_follow_point(first_char)
	
	hud.camera.reset_position()
	hud.camera.reset_zoom()

func initialize_events():
	onetime_events.deserialize(self, level_info.onetime_events)
	repeating_events.deserialize(self, level_info.repeating_events)
	rand_repeat_events.deserialize(self, level_info.rand_repeat_events)
	camera_pan_events.deserialize(self, level_info.camera_pan_events)

func do_countdown(quarter):
	if quarter < 0:
		hud.countdown.stop()
		hud.countdown.stream = countdown_voices[abs(quarter) - 1]
		hud.countdown.play()
		
		if quarter > -4:
			hud.countdown_msgs.show()
			hud.countdown_tween.stop_all()
			hud.countdown_msgs.animation = str(abs(quarter))
			hud.countdown_tween.interpolate_property(hud.countdown_msgs, "modulate:a", 1, 0, Conductor.get_seconds_per_beat(), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			hud.countdown_tween.start()
		
		Conductor.call_deferred("connect", "quarter_hit", self, "do_countdown", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func connect_end_of_song_signal(quarter):
	if quarter == 0:
		Conductor.connect("finished", self, "on_conductor_song_finished")
	else:
		Conductor.call_deferred("connect", "quarter_hit", self, "connect_end_of_song_signal", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func do_post_level_story_event():
	if lvl_manager.in_last_state():
		transition_to_level_exit()
	else:
		TransitionSystem.play_transition(TransitionSystem.Transitions.SCREEN_CAP_OUT)
		end_level_part_2()

func do_post_level_freeplay_event():
	transition_to_level_exit()

func transition_to_level_exit():
	set_process(false)
	set_process_input(false)
	
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
	TransitionSystem.connect("transition_finished", self, "end_level_part_2", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func do_level_cleanup():
	clear_lanes()

# Game Processing

func _process(delta):
	on_update(delta)

func _input(event):
	on_input(event)

func on_update(delta):
	for step_zone_name in step_zones:
		for lane in step_zones[step_zone_name]:
			lane.update_lane(delta)
	
	for char_name in characters:
		if has_character(char_name):
			characters[char_name].on_update(delta)
	
	# If death was caused by the player messing up a note, don't update events
	if dying:
		return
	
	onetime_events.update_events()
	repeating_events.update_events()
	rand_repeat_events.update_events()
	
	# If death was caused by an event, don't update camera movement
	if dying:
		return
	
	camera_pan_events.update_events()
	hud.camera.on_update()
#	hud.update_zoom()

func on_input(event: InputEvent):
	if !get_tree().paused:
		if can_pause && event.is_action_pressed("ui_accept"):
			lvl_manager.set_pause(true)
			return
		
		for lane in step_zones.player:
			if event.is_action(lane.action) && event.is_pressed() != lane.action_pressed:
				lane.check_input(event.pressed)
				break

func update_health(increment, resetting = false):
	if resetting:
		health = increment
	else:
		health = clamp(health + increment, 0, 2)
	
	hud.update_health(health / 2.0)
	
	if health == 0:
		die()

func update_notes_hit(missing = false):
	if missing:
		notes_missed += 1
	else:
		notes_hit += 1
	
	total_hittable_notes += 1

func update_score(increment, resetting = false):
	if resetting:
		score = increment
		total_possible_score = increment
	else:
		score += increment
		total_possible_score += 350

func reset_notes_hit():
	notes_hit = 0
	notes_missed = 0
	total_hittable_notes = 0

func update_combo(increment, rating, resetting = false):
	if resetting:
		var prev_combo = combo
		
		combo = increment
		
		if increment == 0 && prev_combo > 5:
			if has_performer("metronome") && get_performer("metronome").anim_player.has_animation("Sad"):
				get_performer("metronome").play_anim("Sad")
		
		if rating != null:
			create_popup_combo(rating, prev_combo)
	else:
		combo += increment
		create_popup_combo(rating)

func create_popup_combo(rating, custom_combo = null):
	var popup_combo_instance = popup_combo.instance()
	popup_combo_instance.rating_idx = rating
	popup_combo_instance.combo = custom_combo if custom_combo else combo
	hud.ratings_list.add_child(popup_combo_instance)

func update_all_stats(is_sustain_part, missing, data: Dictionary = {}):
	if is_sustain_part:
		if missing:
			update_health(HEALTH_PENALTY_MISS)
		else:
			update_health(HEALTH_BOOST)
		return
	
	if missing:
		update_notes_hit(true)
	
		update_combo(0, null, true)
		update_health(HEALTH_PENALTY_MISS)
	else:
		update_notes_hit()
		
		if data.note_diff > Conductor.SAFE_ZONE * 0.9:
			update_combo(0, Ratings.SHIT, true)
			update_score(50)
			update_health(HEALTH_PENALTY_KE_SHIT)

		elif data.note_diff > Conductor.SAFE_ZONE * 0.75:
			update_combo(1, Ratings.BAD)
			update_score(100)
			update_health(HEALTH_PENALTY_KE_BAD)

		elif data.note_diff > Conductor.SAFE_ZONE * 0.2:
			update_combo(1, Ratings.GOOD)
			update_score(200)
			update_health(HEALTH_BOOST)
		
		else:
			update_combo(1, Ratings.SICK)
			update_score(350)
			update_health(HEALTH_BOOST)
	
	hud.update_score(score, notes_missed, get_rating(get_average_accuracy()), get_display_average_accuracy())

func set_cam_follow_point(char_to_follow):
	var character = get_character_insensitive(char_to_follow)
	
	if character:
		hud.camera.follow_point = character.camera_follow_point
	else:
		hud.camera.follow_point = default_position

func set_custom_cam_follow_point(position_node):
	if position_node:
		hud.camera.follow_point = position_node
	else:
		hud.camera.follow_point = default_position

func die():
	can_pause = false
	dying = true
	
	clear_lanes()
	Conductor.stop_song()
	go_to_death_scene()

func go_to_death_scene():
	if has_performer("player"):
		var player = get_performer("player")
		lvl_manager.die(player.death_scene, player.get_requirements(self))
	else:
		lvl_manager.die(DEFAULT_DEATH_SCENE, {
			"cam_pos_from_level": hud.camera.global_position,
			"zoom_from_level": hud.camera.zoom,
			"player_pos_from_level": get_performer("player").position
		})

func switch_performer(performer_name, character_name, replace = true):
	var prev_performer = get_performer(performer_name)
	
	# Hide the previous performer
	if replace && has_performer(performer_name):
		get_performer(performer_name).hide()
	
	# Set (and show if necessary) the new performer
	set_performer(performer_name, character_name)
	
	if replace:
		get_performer(performer_name).show()
	
	# Adjust parts of the level based on performers if necessary
	if performer_name == "player" || performer_name == "opponent":
		switch_icons(performer_name, performer_name)
	
	if hud.camera.follow_point == prev_performer.camera_follow_point:
		set_cam_follow_point(performer_name)

# TODO: Refactor icons to not depend on child 0

func switch_icons(performer_name, char_or_performer):
	var character = get_character_insensitive(char_or_performer)
	var hud_icon = hud.get(performer_name + "_health_icon")
	
	if character:
		var time_before_replace = 0
		var new_icon = character.icon.instance()
		
		########################
		
		if hud_icon.get_child_count() > 0:
			var cur_icon = hud_icon.get_child(0)
			
			if cur_icon is HealthIcon:
				time_before_replace = cur_icon.get_beat_anim_time()
				cur_icon.queue_free()
		
		########################
		
		hud_icon.add_child(new_icon)
		hud_icon.move_child(new_icon, 0)
		new_icon.set_beat_anim_time(time_before_replace)
	
	hud.update_icons(health / 2.0)

func clear_lanes():
	for step_zone_name in step_zones:
		for lane in step_zones[step_zone_name]:
			lane.clear_lane()

# State Functions

# Player Hit Functions

func hit_note_player(anim_data, strum_time):
	var note_diff = abs(strum_time - Conductor.event_position)
	
	update_all_stats(false, false, {"note_diff": note_diff})
	
	if has_performer("player"):
		get_performer("player").play_anim_for_quarters(anim_data, 1, get_distance_to_next_strum(strum_time, "player"))
	
	Conductor.vocals.volume_db = 0
	hud.stop_miss_sound()

func hit_note_default_player(dir, strum_time):
	hit_note_player(dir, strum_time)

func hit_sustain_part_player(anim_data, strum_time):
	update_all_stats(true, false)
	
	if has_performer("player"):
		get_performer("player").play_anim_for_quarters(anim_data, 1, get_distance_to_next_strum(strum_time, "player"))
	
	Conductor.vocals.volume_db = 0
	hud.stop_miss_sound()

func hit_sustain_part_default_player(dir, strum_time):
	hit_sustain_part_player(dir, strum_time)

# Player Miss Functions

func miss_note_player(anim_data, _strum_time):
	update_all_stats(false, true)
	
	if has_performer("player"):
		get_performer("player").play_anim_for_quarters(anim_data, 5)
	
	Conductor.vocals.volume_db = -80
	hud.play_miss_sound()

func miss_note_default_player(dir, strum_time):
	var anim_data = ""
	
	if has_performer("player"):
		anim_data = get_performer("player").miss_anims[dir]
		
	miss_note_player(anim_data, strum_time)

func miss_sustain_part_player(_dir, _strum_time):
	update_all_stats(true, true)
	Conductor.vocals.volume_db = -80

func miss_sustain_part_default_player(dir, strum_time):
	miss_sustain_part_player(dir, strum_time)

func on_overtap(dir):
	update_health(HEALTH_PENALTY_OVERTAP)
	
	if has_performer("player"):
		var player = get_performer("player")
		player.play_anim_for_quarters(player.miss_anims[dir], 5)
	
	Conductor.vocals.volume_db = -80
	hud.play_miss_sound()

# Opponent Functions

func hit_note_cpu(performer_name, anim_data, strum_time):
	if has_performer(performer_name):
		get_performer(performer_name).play_anim_for_quarters(anim_data, 1, get_distance_to_next_strum(strum_time, performer_name))
	Conductor.vocals.volume_db = 0

func hit_note_default_opponent(dir, strum_time):
	hit_note_cpu("opponent", dir, strum_time)

func hit_sustain_part_default_opponent(dir, strum_time):
	hit_note_cpu("opponent", dir, strum_time)

func miss_note_default_opponent(_dir, _strum_time):
	pass

func miss_sustain_part_default_opponent(_dir, _strum_time):
	pass

func hit_note_default_botplay(dir, strum_time):
	hit_note_default_player(dir, strum_time)

func hit_sustain_part_default_botplay(dir, strum_time):
	hit_sustain_part_default_player(dir, strum_time)

func miss_note_default_botplay(_dir, _strum_time):
	pass

func miss_sustain_part_default_botplay(_dir, _strum_time):
	pass

# Calculations

func get_distance_to_next_strum(strum_time, step_zone_name):
	var next_closest_strum_time = INF
	var lanes = step_zones[step_zone_name]
	
	for lane in lanes:
		var cur_next_closest = lane.get_next_closest_strum_time(strum_time)
		
		if cur_next_closest && cur_next_closest < next_closest_strum_time:
			next_closest_strum_time = next_closest_strum_time
	
	if is_inf(next_closest_strum_time) || next_closest_strum_time - strum_time >= Conductor.get_seconds_per_beat():
		return 0
	return next_closest_strum_time - strum_time

func get_rating(percent):
	if percent == 0.0:
		return "--"
	elif percent < 0.2:
		return "Awful"
	elif percent < 0.4:
		return "Bad"
	elif percent < 0.6:
		return "Okay"
	elif percent > 0.68 && percent < 0.7:
		return "Nice"
	elif percent < 0.8:
		return "Good"
	elif percent < 0.9:
		return "Great"
	elif percent < 0.95:
		return "Sick!"
	elif percent < 1:
		return "Fire!!"
	else:
		return "Perfect!!!"

func get_percent_notes_hit():
	return float(total_hittable_notes - notes_missed) / float(total_hittable_notes)

func get_display_percent_notes_hit():
	return floor(get_percent_notes_hit() * 100)

func get_percent_score_gained():
	if total_possible_score == 0:
		return 0
	return float(score) / float(total_possible_score)

func get_display_percent_score_gained():
	return floor(get_percent_score_gained() * 100)

func get_average_accuracy():
	return (get_percent_notes_hit() + get_percent_score_gained()) / 2.0

func get_display_average_accuracy():
	return floor(get_average_accuracy() * 100)

func on_conductor_song_finished():
	if !(Conductor.stream == null || Conductor.get_playback_position() < Conductor.stream.get_length()):
		end_level_part_1()

# Character functions

func has_character(character_name):
	return characters.has(character_name) && characters[character_name]

func get_character(character_name):
	if has_character(character_name):
		return characters[character_name]
	return null

func has_performer(performer_name):
	return _performers.has(performer_name) && !_performers[performer_name].empty() && \
		   has_character(_performers[performer_name])

func get_performer(performer_name):
	if has_performer(performer_name):
		return get_character(_performers[performer_name])
	return null

func set_performer(performer_name, character_name = ""):
	_performers[performer_name] = character_name

func get_character_insensitive(char_or_performer):
	if char_or_performer in _performers.keys():
		return get_performer(char_or_performer)
	
	# By default get a character, returns null if non-existent
	return get_character(char_or_performer)
