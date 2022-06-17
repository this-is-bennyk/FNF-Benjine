extends Resource
class_name SongList

const DEFAULT_WEEK_LIST = [
	{
		"week_name": "Your Week",
		"level_manager_path": "",
		"week_difficulties": null,
		"song_datas": [],
		"week_logo": null,
		"week_color": Color("#f9cf51")
	}
]

export(Array, Dictionary) var weeks = DEFAULT_WEEK_LIST
export(Array, Resource) var freeplay_songs = []

func _init(weeks_ = DEFAULT_WEEK_LIST, freeplay_songs_ = []):
	weeks = weeks_
	freeplay_songs = freeplay_songs_
