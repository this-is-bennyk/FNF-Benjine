extends Resource
class_name SongData

const DEFAULT_DIFFICULTY_NAMES = [
	"Easy",
	"Normal",
	"Hard"
]

export(String) var name = ""
export(Array, String, FILE, "*.lvl_info.res,*.lvl_info.tres") var level_info_paths = []
export(Array, String) var difficulty_names = DEFAULT_DIFFICULTY_NAMES
export(SpriteFrames) var icons = null
export(int) var icon_index = 0
export(Color) var freeplay_bg_color = Color("#9271fd")
export(Color) var freeplay_outline_color = Color("#2846dc")
export(String, FILE, "*.mp3,*.ogg") var inst_preview_path = ""

func _init(name_ = "",
		   level_info_paths_ = [],
		   difficulty_names_ = DEFAULT_DIFFICULTY_NAMES,
		   icons_ = null,
		   icon_idx = 0,
		   inst_preview_path_ = ""):
	name = name_
	level_info_paths = level_info_paths_
	difficulty_names = difficulty_names_
	icons = icons_
	icon_index = icon_idx
	inst_preview_path = inst_preview_path_
