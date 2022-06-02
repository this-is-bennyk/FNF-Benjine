extends Resource
class_name LevelInfo, "res://scripts/resources/level_info/level_info_icon.svg"

export(Resource) var chart = null
export(PackedScene) var level = null

export(AudioStream) var instrumental_override = null
export(AudioStream) var vocals_override = null

export(Resource) var onetime_events = null
export(Resource) var repeating_events = null
export(Resource) var rand_repeat_events = null
export(Resource) var camera_pan_events = null

func _init(
	chart_: SongChart = null,
	level_: PackedScene = null,
	instrumental_override_: AudioStream = null,
	vocals_override_: AudioStream = null,
	onetime_events_: ResourceList = null,
	repeating_events_: ResourceList = null,
	rand_repeat_events_: ResourceList = null
):
	chart = chart_
	level = level_
	
	instrumental_override = instrumental_override_
	vocals_override = vocals_override_
	
	onetime_events = onetime_events_
	repeating_events = repeating_events_
	rand_repeat_events = rand_repeat_events_
