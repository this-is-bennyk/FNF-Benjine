class_name Note
extends Node

const HIT_PREFIX = "hit"
const MISS_PREFIX = "miss"

const REGULAR_INFIX = "note"
const SUSTAIN_INFIX = "sustain_part"

const DEFAULT_ACTION = "default"

const MAX_JACK_TIME = 1 / 6.0

enum Type {REGULAR, SUSTAIN_LINE, SUSTAIN_CAP}

export(String) var regular_hit_action = "default"
export(String) var sustain_hit_action = "default"

export(String) var regular_miss_action = "default"
export(String) var sustain_miss_action = "default"

export(bool) var ai_miss = false

var strum_time: float
var note_type = Type.REGULAR

func _ready():
	initialize_note()

func initialize_note():
	pass

func do_action(lvl, dir, lane_type_string: String, prefix: String):
	# Construct the function name to call on the level
	var func_name = prefix # Ex. hit_
	var default_func_name = prefix
	
	if note_type == Type.REGULAR:
		# Ex. hit_note_default_
		func_name += "_" + REGULAR_INFIX + "_" + get("regular_" + prefix + "_action")
		default_func_name += "_" + REGULAR_INFIX + "_" + DEFAULT_ACTION
	else:
		func_name += "_" + SUSTAIN_INFIX + "_" + get("sustain_" + prefix + "_action")
		default_func_name += "_" + SUSTAIN_INFIX + "_" + DEFAULT_ACTION
	
	# Ex. hit_note_default_player
	func_name += "_" + lane_type_string
	default_func_name += "_" + lane_type_string
	
	if lvl.has_method(func_name):
		lvl.call(func_name, dir, strum_time)
	else:
		lvl.call(default_func_name, dir, strum_time)

func do_hit_action(lvl, dir, lane_type_string: String):
	do_action(lvl, dir, lane_type_string, HIT_PREFIX)
	queue_free()

func do_miss_action(lvl, dir, lane_type_string: String):
	do_action(lvl, dir, lane_type_string, MISS_PREFIX)

# Remarks: I HATE JACKS I HATE JACKS I HATE JACKS
static func is_regular_hit(prev_note, cur_note, next_note) -> bool:
	var prev_time_diff = cur_note.strum_time - prev_note.strum_time if prev_note else 0
	var next_time_diff = next_note.strum_time - cur_note.strum_time if next_note else 0
	
	# If we don't have a jack pattern, we hit the note
	if !( \
		(next_note && next_time_diff < MAX_JACK_TIME) || \
		(prev_note && prev_time_diff < MAX_JACK_TIME)):
		return true
	
	# Adjust the hit windows
	var jack_early_window = prev_time_diff \
							if prev_note && prev_note.note_type == Type.REGULAR && prev_time_diff <= Conductor.SAFE_ZONE * Conductor.EARLY_HIT_MULT \
							else Conductor.SAFE_ZONE * Conductor.EARLY_HIT_MULT
	var jack_late_window = next_time_diff \
						   if next_note && next_note.note_type == Type.REGULAR && next_time_diff <= Conductor.SAFE_ZONE \
						   else Conductor.SAFE_ZONE
	
	# Check to see if we hit the note with the adjusted windows
	if !(cur_note.strum_time - jack_early_window < Conductor.event_position && \
	   Conductor.event_position < cur_note.strum_time + jack_late_window):
		return false
	
	return true
