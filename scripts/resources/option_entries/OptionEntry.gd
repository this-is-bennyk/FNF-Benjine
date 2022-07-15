extends Resource
class_name OptionEntry

const DEFAULT_OPTIONS = ["Off", "On"]

export(String) var option_name = ""
export(String) var option_display_name = ""

export(Array, String) var options = DEFAULT_OPTIONS

export(bool) var num_range = false
export(int) var num_range_min = 0
export(int) var num_range_max = 0

export(int) var default_option = 0

func _init(
	option_name_: String = "",
	option_display_name_: String = "",
	options_: Array = DEFAULT_OPTIONS,
	num_range_: bool = false,
	num_range_min_: int = 0,
	num_range_max_: int = 0,
	default_option_: int = 0
):
	option_name_ = option_name_
	option_display_name = option_display_name_
	options = options_
	num_range = num_range_
	num_range_min = num_range_min_
	num_range_max = num_range_max_
	default_option = default_option_
