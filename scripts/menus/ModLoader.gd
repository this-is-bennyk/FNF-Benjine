extends Node

const READY_TEXTURE = preload("res://assets/graphics/menus/mod_loader/mod_loader_screen_part_2.png")

onready var bg = $BG
onready var progress_label = $Label
onready var transition_anim = $Polygon2D/AnimationPlayer

func _ready():
	if OS.has_feature("editor") || OS.get_name() == "HTML5":
		if OS.has_feature("editor"):
			for package in UserData.get_package_names():
				UserData.load_keybinds(package)
		get_parent().switch_state(load("res://scenes/shared/menus/default_menus/TitleScreen.tscn"))
	else:
		call_deferred("_load_packages")

func _load_packages():
#	VolumeChanger.disabled = true
#	transition_anim.play("Fade_In")
	print("Loading shit")
	
	########################################
	
	var package_names = UserData.get_package_names()
	var num_basic_mods = 0
	
	for package in package_names:
		if package == "fnf":
			continue
		
		var mod_desc: ModDescription = UserData.get_mod_desc(package)
		if !mod_desc.advanced_mod:
			var mod_path = UserData.get_modpacks_path().plus_file(mod_desc.mod_package_name + ".pck")

			print("Attempting to load mod: " + mod_desc.mod_package_name + " at " + mod_path)
			progress_label.text = "Loading " + mod_desc.mod_package_name + "..."
			yield(get_tree().create_timer(0.5), "timeout")

			var success = ProjectSettings.load_resource_pack(mod_path)
			print("Loading of mod " + mod_desc.mod_package_name + " at " + mod_path + " successful?: " + str(success))
			
			if success:
				UserData.load_keybinds(package)
				num_basic_mods += 1
	
	bg.texture = READY_TEXTURE
	progress_label.text = "Ready! Found " + str(num_basic_mods) + " basic mod(s)."
	yield(get_tree().create_timer(1), "timeout")
	
	########################################
	
	transition_anim.play("Fade_Out")
	yield(transition_anim, "animation_finished")
	
	VolumeChanger.disabled = false
	get_parent().switch_state(load("res://scenes/shared/menus/default_menus/TitleScreen.tscn"))
