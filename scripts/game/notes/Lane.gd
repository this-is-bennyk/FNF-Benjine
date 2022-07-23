class_name Lane
extends Node

#const MAX_JACK_TIME = 1 / 6.0

enum Type {PLAYER, OPPONENT, BOTPLAY, OTHER}

# Lane properties
export(int) var direction = 0
export(Type) var lane_type = Type.PLAYER
export(String) var other_type_name = ""
export(bool) var light_on_strum = true

# NodePaths for lane components
export(NodePath) var strum_arrow_nodepath
export(NodePath) var strum_arrow_anim_nodepath
export(NodePath) var start_path_nodepath
export(NodePath) var end_path_nodepath

# Animation names
export(String) var neutral_anim = "Neutral"
export(String) var lighted_anim = "Lighted"
export(String) var pressed_anim = "Pressed"

# Data from Godot resources
export(String) var action # Name of InputEventAction to check for
export(Array, PackedScene) var note_scenes := [] # Array of scenes that are notes

# Lane components
onready var strum_arrow = get_node(strum_arrow_nodepath)
onready var strum_arrow_anim_player: AnimationPlayer = get_node(strum_arrow_anim_nodepath)
onready var start_path = get_node(start_path_nodepath)
onready var end_path = get_node(end_path_nodepath)

var lvl

var note_data := []
var notes_spawned := []
var notes_in_play := [] # Notes that are ready to be hit (only applies to player)

var action_pressed = false
var strum_arrow_animating = false

var time_offset = 0

var _ghost_tapping = true

func _ready():
	on_ready()

func on_ready():
	get_node(strum_arrow_anim_nodepath).connect("animation_finished", self, "update_strum_anim")
	
	_adjust_for_downscroll()
	_adjust_for_ghost_tapping()

func update_lane(_delta: float) -> void:
	add_notes_from_data()
	update_current_notes()

func clear_lane():
	for note in notes_spawned:
		note.queue_free()
	
	note_data = []
	notes_spawned = []
	notes_in_play = []

func initialize(note_info_array: Array):
	clear_lane()
	
	note_data = note_info_array.duplicate()
	note_data.invert()

func check_input(pressed):
	if lane_type != Type.PLAYER:
		return
	# If we're already pressing / not pressing this lane, avoid a double input
	if pressed == action_pressed:
		return
	
	# Redefine if the action is currently being pressed
	action_pressed = pressed
	
	# Check to see if a user pressed a note
	if pressed:
		# Return if there's no notes ready to be pressed
		if len(notes_in_play) == 0:
			strum_arrow_anim_player.stop()
			strum_arrow_anim_player.play(pressed_anim)
			
			# If there's no ghost tapping, punish the player for hitting in emptiness
			if !_ghost_tapping:
				lvl.on_overtap(direction)
			
			return
		
		_check_for_hit_notes()
	# Otherwise revert the strum arrow back to normal
	else:
		strum_arrow_anim_player.stop()
		strum_arrow_anim_player.play(neutral_anim)

func _check_for_hit_notes():
	# Find if we hit 1 or more notes
		var notes_to_delete = []
		var regular_note_hit = false
		var sustain_note_hit = false
		
		for i in len(notes_in_play):
			var cur_note = notes_in_play[i]
			
			# We don't care about precision for sustained notes
			if cur_note.note_type != Note.Type.REGULAR:
				if sustain_note_hit:
					continue
				
				hit_note(cur_note)
				notes_to_delete.append(cur_note)
				sustain_note_hit = true
			else:
				# If we already hit a regular note on this input, continue
				if regular_note_hit:
					continue
				
				var prev_note = null
				var next_note = null
				
				if i > 0:
					prev_note = notes_in_play[i - 1]
				if i < len(notes_in_play) - 1:
					next_note = notes_in_play[i + 1]
				
				if Note.is_regular_hit(prev_note, cur_note, next_note):
					hit_note(cur_note)
					notes_to_delete.append(cur_note)
					regular_note_hit = true
		
		# If we didn't, play the lane press animation (and punish for non-ghost tapping if necessary)
		if notes_to_delete.empty():
			if !strum_arrow_anim_player.is_playing():
				strum_arrow_anim_player.play(pressed_anim)
			
			if !_ghost_tapping:
				lvl.on_overtap(direction)
		# Otherwise delete the notes we did hit
		else:
			for note in notes_to_delete:
				notes_spawned.erase(note)
				notes_in_play.erase(note)

func add_notes_from_data():
	if note_data.empty():
		return
	
	var cur_note_data = note_data.pop_back()
	
	if Conductor.event_position > cur_note_data.strum_time - Conductor.get_current_spawn_time():
		# Get the note of the desired type (either the default notes or a custom type) and make an instance
		var note_template = note_scenes[cur_note_data.note_type]
		var note_instance = note_template.instance()
		
		# Set the note specific variables
		note_instance.strum_time = cur_note_data.strum_time
		
		if cur_note_data.has("note_data"):
			for variable in cur_note_data.note_data:
				note_instance.set(variable, cur_note_data.note_data[variable])
		
		spawn_note(note_instance)
		
		# If this note is sustained, spawn the appropriate amount of sustained notes
		if cur_note_data.sustain_length > 0:
			# We add 1 for the additional sustain note right on the regular note
			var num_sustain_notes = int(floor(cur_note_data.sustain_length / Conductor.get_sixteenth_length())) + 1
			
			for i in num_sustain_notes:
				# Make an instance
				var sus_note_instance = note_template.instance()
				
				# Set the note specific variables
				sus_note_instance.strum_time = cur_note_data.strum_time + (Conductor.get_sixteenth_length() * i)
				sus_note_instance.note_type = Note.Type.SUSTAIN_CAP \
											  if i == num_sustain_notes - 1 \
											  else Note.Type.SUSTAIN_LINE
				
				if cur_note_data.has("note_data"):
					for variable in cur_note_data.note_data:
						sus_note_instance.set(variable, cur_note_data.note_data[variable])
				
				spawn_note(sus_note_instance)
	else:
		note_data.push_back(cur_note_data)

func update_current_notes():
	var notes_to_delete = []
	
	for note in notes_spawned:
		# Check if note is able to be hit by the player
		if lane_type == Type.PLAYER:
			# If it is able to be hit...
			if Conductor.is_note_in_safe_zone(note.strum_time):
				# ...add it to the list of hittable notes if it isn't there already...
				if !(note in notes_in_play):
					notes_in_play.append(note)
				
				# ...and if it's a sustained note, hit it as soon as it reaches the strum line
				if action_pressed && \
				   (note.note_type == Note.Type.SUSTAIN_LINE || note.note_type == Note.Type.SUSTAIN_CAP) && \
				   Conductor.event_position > note.strum_time:
					hit_note(note)
					notes_to_delete.append(note)
					continue
				
			# Otherwise make the player miss it
			else:
				if Conductor.event_position > note.strum_time && note in notes_in_play:
					note.do_miss_action(lvl, direction, get_lane_type_as_string())
					notes_in_play.erase(note)
		else:
			# If we want the AI to miss the note on purpose, check if we should miss the note
			if note.ai_miss && !Conductor.is_note_in_safe_zone(note.strum_time) && Conductor.event_position > note.strum_time:
				note.do_miss_action(lvl, direction, get_lane_type_as_string())
		
		# Update note movement or delete if needed
		var note_in_start_path = note in start_path.get_children()
		var relative_song_pos = Conductor.get_relative_song_position(note.strum_time, note_in_start_path)
		
		if relative_song_pos > 1:
			if note_in_start_path && (lane_type == Type.PLAYER || note.ai_miss):
				start_path.remove_child(note)
				end_path.add_child(note)
				note.unit_offset = Conductor.get_relative_song_position(note.strum_time, false)
			else:
				# If this is an AI note, hit the note so that it doesn't go beyond the strum line
				if !(lane_type == Type.PLAYER || note.ai_miss):
					hit_note(note)
				# Otherwise this is a player note, and it has reached the end of the end path
				else:
					note.queue_free()
				# Either way, it needs to be deleted
				notes_to_delete.append(note)
		else:
			note.unit_offset = relative_song_pos
	
	for note in notes_to_delete:
		notes_spawned.erase(note)

#		# Assumption: note is in notes_in_play if this lane isn't an AI lane
		if lane_type == Type.PLAYER:
			notes_in_play.erase(note)

func update_strum_anim(_anim_name = ""):
	strum_arrow_anim_player.stop()
	
	if lane_type != Type.PLAYER:
		if strum_arrow_anim_player.assigned_animation == lighted_anim:
			strum_arrow_anim_player.play(neutral_anim)
	else:
		if !action_pressed && strum_arrow_anim_player.assigned_animation != neutral_anim:
			strum_arrow_anim_player.play(neutral_anim)

func spawn_note(note_instance):
	notes_spawned.append(note_instance)
	start_path.add_child(note_instance)

func hit_note(note):
	note.do_hit_action(lvl, direction, get_lane_type_as_string())
	
	if light_on_strum:
		strum_arrow_anim_player.stop()
		strum_arrow_anim_player.play(lighted_anim)

# Returns whether or not a character should idle after this note.
# (Replaces the need for sections of time that a character can't idle for.)
func get_next_closest_strum_time(strum_time):
	var next_note_idx
	
	# Find the closest note index if given a strum time
	# Start at the end
	next_note_idx = len(notes_spawned) - 1
	
	# Decrement the index while we haven't found a close enough note
	while next_note_idx >= 0 && notes_spawned[next_note_idx].strum_time > strum_time:
		next_note_idx -= 1
	
	var next_note_exists = notes_spawned.find(next_note_idx) != -1
	
	# If the note doesn't exist, return a signifier that we didn't find a next closest strum time
	if !next_note_exists:
		return null
	return notes_spawned[next_note_idx].strum_time

func get_lane_type_as_string():
	match lane_type:
		Type.PLAYER:
			return "player"
		Type.OPPONENT:
			return "opponent"
		Type.BOTPLAY:
			return "botplay"
		_:
			return other_type_name

func _adjust_for_downscroll():
	if !UserData.get_setting("downscroll", 0, "gameplay"):
		return
	
	var this = get_parent().get_node(name)
	
	if this is Spatial:
		this.rotation_degrees.z += 180
		strum_arrow.rotation_degrees.z += 180
	else:
		this.rotation_degrees += 180
		strum_arrow.rotation_degrees += 180

func _adjust_for_ghost_tapping():
	_ghost_tapping = bool(UserData.get_setting("ghost_tapping", 1, "gameplay"))
