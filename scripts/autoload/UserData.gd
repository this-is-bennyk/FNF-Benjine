extends Node

const SETTINGS_DATA_PATH: String = "user://FNF_Benjine_Settings.data"
const SAVE_DATA_PATH: String = "user://FNF_Benjine_Save.data"
const IMPORTED_PACKAGES_PATH: String = "res://packages"
const DEFAULT_SETTINGS_PATH: String = "res://assets/data/default_settings.data"
#const DEFAULT_OVERRIDE_SETTINGS_PATH: String = "res://assets/data/default_override.cfg"

#func get_override_settings_path():
#	return "res://override.cfg" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().plus_file("override.cfg")

func get_modpacks_path():
	return "res://testing/mods" if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().plus_file("mods")

func _ready():
	_attempt_first_time_setup()

func _attempt_first_time_setup():
	var directory = Directory.new()
	
	if !directory.file_exists(SETTINGS_DATA_PATH):
		var default_settings = load_data(DEFAULT_SETTINGS_PATH)
		save_data(SETTINGS_DATA_PATH, default_settings)
	
	if !directory.file_exists(SAVE_DATA_PATH):
		save_data(SAVE_DATA_PATH, {})
	
#	if !directory.file_exists(get_override_settings_path()):
#		var cfg = ConfigFile.new()
#		cfg.load(DEFAULT_OVERRIDE_SETTINGS_PATH)
#		cfg.save(get_override_settings_path())
	
	if !directory.dir_exists(get_modpacks_path()):
		var err = directory.make_dir(get_modpacks_path())
		print("Make modpack dir: " + str(err))
	else:
		print("Modpack dir: " + get_modpacks_path())
	
	_set_immediate_priority_settings()

func save_data(path: String, dict: Dictionary):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(var2str(dict))
	file.close()

func load_data(path: String):
	var file = File.new()
	var dict: Dictionary
	
	file.open(path, File.READ)
	dict = str2var(file.get_as_text())
	file.close()
	
	return dict

func _set_immediate_priority_settings():
	# TODO: Abstract this
	
	# Set audio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(float(UserData.get_setting("Master", 10, "audio")) / 10.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(float(UserData.get_setting("Music", 10, "audio")) / 10.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(float(UserData.get_setting("SFX", 10, "audio")) / 10.0))
	
	# Set fullscreen
	OS.window_fullscreen = bool(UserData.get_setting("fullscreen", 0, "gameplay"))
	
	# Set inputs
	var settings = load_data(SETTINGS_DATA_PATH)
	
	for category in settings.keys():
		var inputs = settings[category]["input"]
		
		for input_name in inputs.keys():
			if input_name == "order":
				continue
			
			InputMap.action_erase_events(input_name)
			InputMap.action_add_event(input_name, inputs[input_name])

func is_valid_mod(package: String):
	if package == "fnf":
		return true
	
	var directory = Directory.new()
	var has_mod_desc = directory.file_exists(IMPORTED_PACKAGES_PATH.plus_file(package).plus_file("mod_desc.tres"))
	var has_credits = directory.file_exists(IMPORTED_PACKAGES_PATH.plus_file(package).plus_file("credits.tres"))
	
	return has_mod_desc && has_credits

func is_basic_mod(package: String):
	if package == "fnf":
		return true
	
	if is_valid_mod(package):
		var mod_desc: ModDescription = load(IMPORTED_PACKAGES_PATH.plus_file(package).plus_file("mod_desc.tres"))
		return !mod_desc.advanced_mod
	return false

func get_mod_desc(package: String):
	if !is_valid_mod(package):
		return null
	
	return load(IMPORTED_PACKAGES_PATH.plus_file(package).plus_file("mod_desc.tres"))

func get_setting(setting: String, default_val = null, category: String = "", package: String = "general"):
	var cur_settings = load_data(SETTINGS_DATA_PATH)
	
	if !category.empty():
		if !(cur_settings.has(package) && cur_settings[package].has(category) && cur_settings[package][category].has(setting)):
			set_setting(setting, default_val, category, package)
			return default_val
		
		return cur_settings[package][category][setting]
	else:
		if !(cur_settings.has(package) && cur_settings[package].has(setting)):
			set_setting(setting, default_val, category, package)
			return default_val
		
		return cur_settings[package][setting]

func get_settings_in_category(category: String, package: String = "general"):
	var cur_settings = load_data(SETTINGS_DATA_PATH)

	if !(cur_settings.has(package) && cur_settings[package].has(category)):
		return null

	return cur_settings[package][category]

func get_package_names():
	var directory = Directory.new()
	var package_names = []
	
	directory.open(IMPORTED_PACKAGES_PATH)
	directory.list_dir_begin()
	
	var file_name = directory.get_next()
	
	while file_name != "":
		if directory.current_is_dir() && !file_name.begins_with(".") && is_valid_mod(file_name):
			package_names.append(file_name)
		file_name = directory.get_next()
	
	directory.list_dir_end()
	
	return package_names

func set_setting(setting: String, variant, category: String = "", package: String = "general"):
	var cur_settings = load_data(SETTINGS_DATA_PATH)
	
	if !cur_settings.has(package):
		cur_settings[package] = {}
	
	if !category.empty():
		if !cur_settings[package].has(category):
			cur_settings[package][category] = {}
		
		cur_settings[package][category][setting] = variant
	else:
		cur_settings[package][setting] = variant
	
	save_data(SETTINGS_DATA_PATH, cur_settings)

func get_song_score(song_name: String, difficulty: String, package: String = "fnf"):
	var cur_save = load_data(SAVE_DATA_PATH)
	
	if !(cur_save.has(package) && cur_save[package].has(song_name) && cur_save[package][song_name].has(difficulty)):
		return 0
	
	return cur_save[package][song_name][difficulty]

func set_song_score(song_name: String, difficulty: String, score: int, package: String = "fnf"):
	var cur_save = load_data(SAVE_DATA_PATH)
	
	if !cur_save.has(package):
		cur_save[package] = {}
	
	if !cur_save[package].has(song_name):
		cur_save[package][song_name] = {}
	
	cur_save[package][song_name][difficulty] = score
	
	save_data(SAVE_DATA_PATH, cur_save)

func get_entire_basic_mod_freeplay_list():
	var basic_mod_freeplay_list = []
	var package_names = get_package_names()
	
	basic_mod_freeplay_list.append_array(_get_basic_mod_freeplay_list("fnf"))
	
	for package_name in package_names:
		if package_name != "fnf":
			basic_mod_freeplay_list.append_array(_get_basic_mod_freeplay_list(package_name))
	
	return basic_mod_freeplay_list

func _get_basic_mod_freeplay_list(package: String):
	var directory = Directory.new()
	var path = IMPORTED_PACKAGES_PATH
	path = path.plus_file(package).plus_file("songs")
	
	var data_path_err = directory.open(path)
	if !is_valid_mod(package) || !is_basic_mod(package) || data_path_err || !directory.file_exists("song_list.tres"):
		return []
	
	path = path.plus_file("song_list.tres")
	
	var song_list = load(path)
	var freeplay_list = []
	
	for week in song_list.weeks:
		freeplay_list.append_array(week.song_datas)
	
	freeplay_list.append_array(song_list.freeplay_songs)
	
	return freeplay_list

func get_entire_basic_mod_weeks_list():
	var basic_mod_weeks_list = []
	var package_names = get_package_names()
	
	basic_mod_weeks_list.append_array(_get_basic_mod_week_list("fnf"))
	
	for package_name in package_names:
		if package_name != "fnf":
			basic_mod_weeks_list.append_array(_get_basic_mod_week_list(package_name))
	
	return basic_mod_weeks_list

func _get_basic_mod_week_list(package: String):
	var directory = Directory.new()
	var path = IMPORTED_PACKAGES_PATH
	path = path.plus_file(package).plus_file("songs")
	
	var data_path_err = directory.open(path)
	if !is_valid_mod(package) || !is_basic_mod(package) || data_path_err || !directory.file_exists("song_list.tres"):
		return []
	
	path = path.plus_file("song_list.tres")
	
	var song_list = load(path)
	var week_list = []
	
	for week in song_list.weeks:
		if week.has_all(["level_manager_path", "song_datas", "week_difficulties"]):
			week_list.append(week)
	
	return week_list

func get_package_based_on_song_data(song_data: SongData):
	var package_path = song_data.resource_path.get_base_dir()
	
	package_path = package_path.trim_prefix(IMPORTED_PACKAGES_PATH + "/")
	
	var package_path_split = package_path.split("/")
	
	return package_path_split[0]

#func get_override_setting(section: String, key: String, default_val = null):
#	var cfg = ConfigFile.new()
#	cfg.load(get_override_settings_path())
#
#	return cfg.get_value(section, key, default_val)
#
#func set_override_setting(section: String, key: String, value):
#	var cfg = ConfigFile.new()
#	cfg.load(get_override_settings_path())
#
#	cfg.set_value(section, key, value)
#	cfg.save(get_override_settings_path())
#
#func get_override_section_keys(section: String):
#	var cfg = ConfigFile.new()
#	cfg.load(get_override_settings_path())
#
#	if cfg.has_section(section):
#		return cfg.get_section_keys(section)
