extends Node

const BENJINE_DESC = preload("res://assets/data/benjine_desc.tres")
const DEFAULT_BANNER = preload("res://assets/graphics/menus/advanced_mods/benjine_mod_banner.png")

onready var button_container = $BG_Options/ScrollContainer/VBoxContainer
onready var button_template = $Button_Template

onready var banner = $Banner
onready var description = $Description
onready var launch_button = $Launch

onready var select_sound = $Select_Sound

onready var camera = $Camera2D
onready var camera_anim = $Camera2D/AnimationPlayer
onready var loading_label = $Camera2D/Label

var mod_descs := []
var mod_desc_map :=  {}
var button_group := ButtonGroup.new()

var cur_option = "Base Benjine"

func _ready():
	# Find all the advanced mod descriptions
	mod_descs.append(BENJINE_DESC)

	for package in UserData.get_package_names():
		if package == "fnf":
			continue
		
		var mod_desc: ModDescription = UserData.get_mod_desc(package)
		
		if mod_desc.advanced_mod:
			mod_descs.append(mod_desc)
	
	# If there's only the Benjine, jump directly into it
	if len(mod_descs) == 1:
		get_tree().change_scene(BENJINE_DESC.main_path)
		return

	# Parse the buttons for the advanced mods
	for mod_desc in mod_descs:
		var button = button_template.duplicate()
		
		button.text = mod_desc.mod_name
		button.group = button_group
		button.connect("focus_entered", self, "_on_mod_name_pressed", [mod_desc.mod_name])
		
		button_container.add_child(button)
		mod_desc_map[mod_desc.mod_name] = mod_desc
	
	# Initialize the scene
	button_template.hide()
	_on_mod_name_pressed("Base Benjine", false)
	
	camera_anim.play("Fade_In")

func _on_mod_name_pressed(mod_name: String, play_sound: bool = true):
	var mod_desc: ModDescription = mod_desc_map[mod_name]
	
	if mod_desc.banner:
		banner.material.set_shader_param("img", mod_desc.banner)
	else:
		banner.material.set_shader_param("img", DEFAULT_BANNER)
	
	description.parse_bbcode(mod_desc.description)
	if play_sound:
		select_sound.play()
	
	cur_option = mod_name

func _on_launch_pressed():
	for button in button_container.get_children():
		button.disabled = true
	launch_button.disabled = true
	
	camera_anim.play("Fade_Out")
	yield(camera_anim, "animation_finished")
	
	var mod_desc: ModDescription = mod_desc_map[cur_option]
	
	if !(cur_option == "Base Benjine" || OS.has_feature("editor")):
		var mod_path = UserData.get_modpacks_path().plus_file(mod_desc.mod_package_name + ".pck")
		
		camera.zoom = Vector2.ONE
		loading_label.show()
		loading_label.text = "Loading " + cur_option + "..."
		
		print("Loading advanced mod")
		var success = ProjectSettings.load_resource_pack(mod_path)
		print("Loading of advanced mod" + cur_option + " at " + mod_path + " successful?: " + str(success))
	
	get_tree().change_scene(mod_desc.main_path)
