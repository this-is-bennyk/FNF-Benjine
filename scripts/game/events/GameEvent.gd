extends Reference
class_name GameEvent

var occurrence_time = 0
var time_units = -1
var check_floored_time := false

var func_ref: FuncRef
var func_args: Array

func _init(
		occurrence_time_ = 0,
		time_units_ = -1,
		func_ref_: FuncRef = null,
		func_args_: Array = [],
		check_floored_time_: bool = false):
	occurrence_time = occurrence_time_
	time_units = time_units_
	func_ref = func_ref_
	func_args = func_args_
	check_floored_time = check_floored_time_

func deserialize(level: Node, event_info) -> void:
	occurrence_time = event_info.occurrence_time
	time_units = event_info.time_units
	
	if !event_info.func_ref_property_path.empty() && GodotX.is_property_path(event_info.func_ref_property_path):
		var node = level.get_node(event_info.func_ref_nodepath)
		var property = node.get_indexed(event_info.func_ref_property_path)
		func_ref = funcref(property, event_info.func_ref_func_name)
	else:
		func_ref = funcref(level.get_node(event_info.func_ref_nodepath), event_info.func_ref_func_name)
	
	func_args = event_info.func_ref_args
	check_floored_time = event_info.check_floored_time

func ready_to_occur():
	return get_time_to_compare(time_units, check_floored_time) >= occurrence_time

func occur():
	func_ref.call_funcv(func_args)

static func get_time_to_compare(units, floored):
	match units:
		Conductor.Notes.QUARTER:
			return Conductor.get_quarter(floored)
#		Conductor.Notes.EIGHTH:
#			return Conductor.get_eighth(floored)
#		Conductor.Notes.SIXTEENTH:
#			return Conductor.get_sixteenth(floored)
		_:
			return Conductor.event_position
