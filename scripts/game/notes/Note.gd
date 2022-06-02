class_name Note
extends Node

const HIT_PREFIX = "hit"
const MISS_PREFIX = "miss"

const REGULAR_INFIX = "note"
const SUSTAIN_INFIX = "sustain_part"

const DEFAULT_ACTION = "default"

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
