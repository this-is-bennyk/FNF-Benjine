extends Node

const READY_TEXTURE = preload("res://assets/graphics/menus/mod_loader/mod_loader_screen_part_2.png")

onready var bg = $BG
onready var progress_label = $Label

func _ready():
	# TODO: Debug _has_mods
#	if OS.has_feature("editor") || !_has_mods():
	if OS.has_feature("editor"):
		get_parent().switch_state(load("res://scenes/shared/menus/default_menus/TitleScreen.tscn"))
	else:
		call_deferred("_load_packages")

func _load_packages():
	VolumeChanger.disabled = true
	
	########################################
	
	var directory = Directory.new()

	# At this point, the mods folder exists or has been created
	directory.open(UserData.get_modpacks_path())
	directory.list_dir_begin()

	var file_name = directory.get_next()

	while file_name != "":
		if !directory.current_is_dir() && file_name.get_extension() == "pck":
			var mod_path = UserData.get_modpacks_path().plus_file(file_name)

			print("Attempting to load mod: " + file_name + " at " + mod_path)
			progress_label.text = "Loading " + file_name + "..."
			yield(get_tree().create_timer(1), "timeout")

			var success = ProjectSettings.load_resource_pack(mod_path)
			print("Loading of mod " + file_name + " at " + mod_path + " successful?: " + str(success))

		file_name = directory.get_next()
	
	bg.texture = READY_TEXTURE
	progress_label.text = "All done!"
	yield(get_tree().create_timer(1), "timeout")
	
	########################################
	
	VolumeChanger.disabled = false
	get_parent().switch_state(load("res://scenes/shared/menus/default_menus/TitleScreen.tscn"))

func _has_mods():
	var directory = Directory.new()
	# At this point, the mods folder exists or has been created
	directory.open(UserData.get_modpacks_path())
	directory.list_dir_begin()

	var file_name = directory.get_next()
	
	if file_name != "" && !directory.current_is_dir() && file_name.get_extension() == "pck":
		return true
	return false
