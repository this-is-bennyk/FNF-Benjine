extends GameEventInfo
class_name RepeatingGameEventInfo

export(float) var time_increment : float = 0

func _init(occurrence_time_: float = 0,
		time_units_ = -1,
		check_floored_time_: bool = false,
		func_ref_nodepath_ : String = ".",
		func_ref_property_path_ : String = "",
		func_ref_func_name_ : String = "",
		func_ref_args_ : Array = [],
		time_increment_ : float = 0):
	._init(
		occurrence_time_,
		time_units_,
		check_floored_time_,
		func_ref_nodepath_,
		func_ref_property_path_,
		func_ref_func_name_,
		func_ref_args_
	)
	time_increment = time_increment_
