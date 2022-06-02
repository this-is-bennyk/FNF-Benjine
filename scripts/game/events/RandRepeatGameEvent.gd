extends RepeatingGameEvent
class_name RandRepeatGameEvent

var generate_with_ints: bool = false
var inclusive_int_range: bool = true

func _init(
		occurrence_time_ = 0,
		time_units_ = -1,
		func_ref_: FuncRef = null,
		func_args_: Array = [],
		check_floored_time_: bool = false,
		time_increment_ = [],
		generate_with_ints_: bool = false,
		inclusive_int_range_: bool = true):
	._init(
		occurrence_time_,
		time_units_,
		func_ref_,
		func_args_,
		check_floored_time_,
		time_increment_
	)
	generate_with_ints = generate_with_ints_
	inclusive_int_range = inclusive_int_range_

func deserialize(level: Node, event_info) -> void:
	.deserialize(level, event_info)
	generate_with_ints = event_info.generate_with_ints
	inclusive_int_range = event_info.inclusive_int_range

func increase_occurrence_time():
	var min_time = time_increment[0]
	var max_time = time_increment[1]

	var generated_increment

	if generate_with_ints:
		var time_range = max_time - min_time

		if inclusive_int_range:
			time_range += 1

		generated_increment = (randi() % time_range) + min_time

	else:
		generated_increment = rand_range(min_time, max_time)

	occurrence_time += generated_increment
