tool
extends Node

const PSYCH_GF_SING = "GF Sing"
const MIN_TIME_BTWN_NOTES = 0.001

# "Exports"
var json_name = ""
var mod_name = ""
var inst_name_and_ext = "Inst.ogg"
var vocals_name_and_ext = "Voices.ogg"
var result_suffixes = ["_easy", "_normal", "_hard"]

var chart_type = SongChart.ChartType.SNIFF
var difficulties = PoolIntArray([0, 1, 2])
var fnf_chart_naming = false
var num_lanes = 4

var psych_separate_gf_lanes = false

var song_dict
var addt_data = {}
var inst
var vocals = null

var _song_chart: SongChart
var _lvl_info: LevelInfo

func _get_property_list():
	var properties = []
	
	properties.append({
		name = "File Names",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	properties.append({
		name = "json_name",
		type = TYPE_STRING
	})
	properties.append({
		name = "mod_name",
		type = TYPE_STRING
	})
	properties.append({
		name = "inst_name_and_ext",
		type = TYPE_STRING
	})
	properties.append({
		name = "vocals_name_and_ext",
		type = TYPE_STRING
	})
	properties.append({
		name = "result_suffixes",
		type = TYPE_ARRAY
	})
	
	properties.append({
		name = "Chart Properties",
		type = TYPE_NIL,
		usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	properties.append({
		name = "chart_type",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = PoolStringArray(SongChart.ChartType.keys()).join(",")
	})
	properties.append({
		name = "difficulties",
		type = TYPE_INT_ARRAY
	})
	properties.append({
		name = "fnf_chart_naming",
		type = TYPE_BOOL
	})
	properties.append({
		name = "num_lanes",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1,4,1,or_greater"
	})
	
	properties.append({
		name = "Psych Engine",
		type = TYPE_NIL,
		hint_string = "psych_",
		usage = PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SCRIPT_VARIABLE
	})
	
	properties.append({
		name = "psych_separate_gf_lanes",
		type = TYPE_BOOL
	})
	
	return properties

func _ready():
	if Engine.editor_hint: return
	
	for difficulty_idx in range(difficulties.size()):
		############
		# Chart Stuff
		
		_song_chart = SongChart.new()
		print("Song chart resource created")
		yield(get_tree().create_timer(0.01), "timeout")
		
		extract_data_from_json(difficulties[difficulty_idx])
		print("Data extracted from JSON")
		yield(get_tree().create_timer(0.01), "timeout")
		
		generate_bpm_maps()
		print("BPMs mapped")
		yield(get_tree().create_timer(0.01), "timeout")
		
		generate_notes()
		print("Notes generated")
		yield(get_tree().create_timer(0.01), "timeout")
		
		_song_chart.instrumental = inst
		_song_chart.vocals = vocals
		
		_song_chart.initial_bpm = song_dict.bpm
		_song_chart.scroll_speed = song_dict.speed
		
		var err = ResourceSaver.save("res://packages/" + mod_name + "/songs/" + json_name + "/" + json_name + result_suffixes[difficulty_idx] + ".chart.res", _song_chart, ResourceSaver.FLAG_COMPRESS)
		if err == OK:
			print("Chart saved")
		else:
			push_error("Error on chart save: " + str(err))
		yield(get_tree().create_timer(0.01), "timeout")
		
		############
		# Level Stuff
		
		_lvl_info = LevelInfo.new()
		_lvl_info.camera_pan_events = ResourceList.new()
		print("Level info resource created")
		yield(get_tree().create_timer(0.01), "timeout")
		
		generate_events()
		yield(get_tree().create_timer(0.01), "timeout")
		
		generate_camera_pan_events()
		print("Camera panning events generated")
		yield(get_tree().create_timer(0.01), "timeout")
		
		err = ResourceSaver.save("res://packages/" + mod_name + "/songs/" + json_name + "/" + json_name + result_suffixes[difficulty_idx] + ".lvl_info.res", _lvl_info, ResourceSaver.FLAG_COMPRESS)
		if err == OK:
			print("Level info saved, be sure to add the chart + level from the FileSystem")
		else:
			push_error("Error on level info save: " + str(err))
		yield(get_tree().create_timer(0.01), "timeout")
		
		############
		
		print("Done: " + json_name + result_suffixes[difficulty_idx])
		print()
		yield(get_tree().create_timer(0.1), "timeout")

func extract_data_from_json(difficulty):
	var path_prefix = "res://packages/" + mod_name + "/songs/" + json_name
	var file = File.new()
	
	var parsed_song
	
	if fnf_chart_naming:
		var suffix = ""
		match difficulty:
			0:
				suffix = "-easy"
			2:
				suffix = "-hard"
		file.open(path_prefix + "/" + json_name + suffix + ".json", File.READ)
	else:
		file.open(path_prefix + "/difficulty" + str(difficulty) + ".json", File.READ)
	parsed_song = JSON.parse(file.get_as_text()).result
	
	match chart_type:
		SongChart.ChartType.FNFVR:
			song_dict = parsed_song
		
		SongChart.ChartType.KADE_V6PLUS:
			song_dict = parsed_song.song
			
			if song_dict.has("eventObjects"):
				addt_data.eventObjects = parsed_song.song.eventObjects
		
		_: # ChartType.SNIFF / engines that don't change the structure of the JSONS much
			song_dict = parsed_song.song
	
	inst = load(path_prefix + "/" + inst_name_and_ext)

	if !vocals_name_and_ext.empty():
		vocals = load(path_prefix + "/" + vocals_name_and_ext)
	
#	name = "",
#   inst = null,
#   voc = null,
#   chart_type_ = ChartType.SNIFF,
#   bpm = 100,
#   scroll_speed_ = 1,
#   sections_ = [],
#   addt_data = {}
#	song_dict.song, inst, vocals, chart_type, song_dict.bpm, song_dict.speed, song_dict.notes, addt_data
	
	file.close()

################################################################################
# BPM Mapping
################################################################################

func generate_bpm_maps():
	match chart_type:
		SongChart.ChartType.KADE_V6PLUS:
			_generate_bpm_maps_with_kade_v6plus()
		_:
			_generate_bpm_maps_with_fnf()

func _generate_bpm_maps_with_fnf():
	# How far we are into the song in quarter notes
	var cumulative_section_quarters = 0
	
	# How far the last BPM change was into the song in quarter notes and seconds
	var prev_section_quarters = 0
	var prev_section_time = 0
	
	# The BPM for the duration of this BPM map
	var cur_bpm = song_dict.bpm
	
	# Find every time the BPM changes, put it in a map, and add it to the set of maps
	for i in len(song_dict.notes):
		var section = song_dict.notes[i] # Current set of notes
		
		if section.has("changeBPM") && section.changeBPM:
			# The amount of time that's already passed
			# (the previous section's time + the amount of time for this section)
			var new_time = prev_section_time + (cumulative_section_quarters - prev_section_quarters) * Conductor.get_seconds_per_beat(cur_bpm)
			
			# Add the new map with the beat we're transforming to,
			# the amount of time it will take to transform, and this section's BPM
			_song_chart.bpm_maps.append({
				end_beat = cumulative_section_quarters,
				bpm = cur_bpm,
				time = new_time
			})
			
			prev_section_quarters = cumulative_section_quarters
			prev_section_time = new_time
			cur_bpm = section.bpm
		
		# Advance the number of quarters we've already been through
		cumulative_section_quarters += section["lengthInSteps"] / 4.0
	
	var song_length = inst.get_length()
	var last_end_beat = prev_section_quarters + (song_length - prev_section_time) / Conductor.get_seconds_per_beat(cur_bpm)
	
	# Add an additional map that describes the last beat we're transforming to
	# (since it doesn't happen in the for loop)
	_song_chart.bpm_maps.append({
				end_beat = last_end_beat,
				bpm = cur_bpm,
				time = song_length
			})

func _generate_bpm_maps_with_kade_v6plus():
	# How far the last BPM change was into the song in quarter notes and seconds
	var prev_section_quarters = 0
	var prev_section_time = 0
	
	# The BPM for the duration of this BPM map
	var cur_bpm = song_dict.bpm
		
	if addt_data.has("eventObjects"):
		for event in addt_data.eventObjects:
			if event.type == "BPM Change" && event.name != "Init BPM":
				var new_time = prev_section_time + (event.position - prev_section_quarters) * Conductor.get_seconds_per_beat(cur_bpm)
				
				_song_chart.bpm_maps.append({
					end_beat = event.position,
					bpm = cur_bpm,
					time = new_time
				})
				
				prev_section_quarters = event.position
				prev_section_time = new_time
				cur_bpm = event.value
		
	var song_length = inst.get_length()
	var last_end_beat = prev_section_quarters + (song_length - prev_section_time) / Conductor.get_seconds_per_beat(cur_bpm)
	
	# Add an additional map that describes the last beat we're transforming to
	# (since it doesn't happen in the for loop / may not happen at all if there's no bpm changes)
	_song_chart.bpm_maps.append({
					end_beat = last_end_beat,
					bpm = cur_bpm,
					time = song_length
				})

################################################################################
# Note Generation
################################################################################

func generate_notes():
	###############
	# Initialize note info arrays
	
	var player_notes_arrays = []
	for i in num_lanes:
		player_notes_arrays.append([])
	
	var opponent_notes_arrays = []
	for i in num_lanes:
		opponent_notes_arrays.append([])
	
	var psych_gf_notes_arrays = null
	if chart_type == SongChart.ChartType.PSYCH && psych_separate_gf_lanes:
		psych_gf_notes_arrays = []
		
		for i in num_lanes:
			psych_gf_notes_arrays.append([])
	
	###############
	# Parse notes
	
	for section in song_dict.notes:
		for note in section.sectionNotes:
			var current_note_arr = player_notes_arrays if section.mustHitSection else opponent_notes_arrays
			var opposing_note_arr = opponent_notes_arrays if section.mustHitSection else player_notes_arrays
			
			var parsed_note = {
				strum_time = note[0] / 1000.0,
				sustain_length = note[2] / 1000.0,
				note_type = 0
			}
			var direction = int(note[1])
			
			# Put the notes into the second opponent lanes if necessary
			if psych_gf_notes_arrays && len(note) > 3 && note[3] == PSYCH_GF_SING:
				psych_gf_notes_arrays[direction % len(psych_gf_notes_arrays)].append(parsed_note)
				continue
			
			# Otherwise put them into the player or opponent lanes correspondingly
			if direction >= len(current_note_arr):
				opposing_note_arr[direction % len(current_note_arr)].append(parsed_note)
			else:
				current_note_arr[direction].append(parsed_note)
	
	###############
	# Clean up and sort note arrays
	
	for lane in player_notes_arrays:
		_sort_notes(lane)
		_delete_duplicate_notes(lane)
	
	for lane in opponent_notes_arrays:
		_sort_notes(lane)
		_delete_duplicate_notes(lane)
	
	if psych_gf_notes_arrays:
		for lane in psych_gf_notes_arrays:
			_sort_notes(lane)
			_delete_duplicate_notes(lane)
	
	###############
	# Put the lanes in the chart
	
	_song_chart.lanes.player = player_notes_arrays
	_song_chart.lanes.opponent = opponent_notes_arrays
	
	if psych_gf_notes_arrays:
		_song_chart.lanes.opponent2 = psych_gf_notes_arrays

func _sort_notes(lane):
	lane.sort_custom(NoteSort, "sort_ascending_by_strum_time")

func _delete_duplicate_notes(lane):
	var duplicates = []
	
	for i in range(0, len(lane) - 1):
		var cur_strum = lane[i].strum_time
		var next_strum = lane[i + 1].strum_time
		
		if next_strum - cur_strum < MIN_TIME_BTWN_NOTES:
			# Put in reverse order to erase duplicates properly
			duplicates.push_front(i)
	
	for dup_idx in duplicates:
		lane.remove(dup_idx)

class NoteSort:
	static func sort_ascending_by_strum_time(a, b):
		return a.strum_time < b.strum_time

################################################################################
# Event Generation
################################################################################

func generate_events():
	match chart_type:
		SongChart.ChartType.KADE_V6PLUS:
			print("Level-specific events detected")
			_lvl_info.onetime_events = ResourceList.new()
			_generate_kade_v6plus_events()
			print("Level-specific events generated")

func _generate_kade_v6plus_events():
	if addt_data.has("eventObjects"):
		for event in addt_data.eventObjects:
			if event.type == "Scroll Speed Change":
				_lvl_info.onetime_events.list.append(
					GameEventInfo.new(
						event.position,
						Conductor.Notes.QUARTER,
						false,
						"/root/Conductor",
						"",
						"set",
						["scroll_speed", event.value]
					)
				)

func generate_camera_pan_events():
	var current_quarters = 0
	var prev_section = null
	
	for section in song_dict.notes:
		if (!prev_section) || (prev_section.mustHitSection != section.mustHitSection):
			add_camera_pan_event(section, current_quarters)
		prev_section = section
		
		current_quarters += section.lengthInSteps / 4.0

func add_camera_pan_event(section, cur_quarters):
	if section.mustHitSection:
		_lvl_info.camera_pan_events.list.append(get_pan_event(cur_quarters, "player"))
	else:
		_lvl_info.camera_pan_events.list.append(get_pan_event(cur_quarters, "opponent"))

func get_pan_event(cur_quarters, character):
	return GameEventInfo.new(
				cur_quarters,
				Conductor.Notes.QUARTER,
				false,
				".",
				"",
				"set_cam_follow_point",
				[character]
			)
