extends GameEvent
class_name RepeatingGameEvent

var time_increment = 0

# PRECONDITION: Incremental time is a non-zero positive number
func _init(
		occurrence_time_ = 0,
		time_units_ = -1,
		func_ref_: FuncRef = null,
		func_args_: Array = [],
		check_floored_time_: bool = false,
		time_increment_ = 0):
	._init(
		occurrence_time_,
		time_units_,
		func_ref_,
		func_args_,
		check_floored_time_
	)
	time_increment = time_increment_

func deserialize(level: Node, event_info) -> void:
	.deserialize(level, event_info)
	time_increment = event_info.time_increment

func increase_occurrence_time():
	occurrence_time += time_increment

#func increase_occurrence_time():
#	data.occurrence_time += data.time_increment

#static func get_minimum_params():
#	return {
#		"occurrence_time": 0,
#		"time_units": -1,
#		"check_floored_time": false,
#
#		"nodepath": NodePath("."),
#		"function": "",
#		"func_args": [],
#		"time_increment": 0
#	}
