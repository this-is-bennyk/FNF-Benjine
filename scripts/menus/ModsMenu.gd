extends Node

const BENJINE_DESC = preload("res://assets/data/benjine_desc.tres")
const DEFAULT_BANNER = preload("res://assets/graphics/menus/mods/benjine_mod_banner.png")

const MAIN_MENU = preload("res://scenes/shared/menus/default_menus/MainMenu.tscn")
const CANCEL_SOUND = preload("res://assets/sounds/cancelMenu.ogg")

onready var title = $Title

onready var button_container = $BG_Options/ScrollContainer/VBoxContainer
onready var button_template = $Button_Template

onready var banner = $Banner
onready var author_info = $Author_Info
onready var description = $Description
onready var launch_button = $Launch

onready var select_sound = $Select_Sound
onready var music = $Music

var advanced_mods = true

var mod_descs := []
var mod_desc_map :=  {}
var package_name_map := {}
var button_group := ButtonGroup.new()

var cur_option = "Base Benjine"

func _ready():
	for package in UserData.get_package_names():
		if package == "fnf":
			continue
		
		var mod_desc: ModDescription = UserData.get_mod_desc(package)
		
		if mod_desc.advanced_mod == advanced_mods:
			mod_descs.append(mod_desc)
			
			package_name_map[mod_desc.mod_name] = package

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
	
	if !advanced_mods:
		title.text = "Basic Mods"
		launch_button.hide()
		description.rect_size.y += 85
	
	music.play()
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func _input(event):
	on_input(event)

func on_input(event):
	if event.is_action_released("ui_cancel"):
		set_process_input(false)
		
		for button in button_container.get_children():
			button.disabled = true
		launch_button.disabled = true
		
		select_sound.stop()
		select_sound.stream = CANCEL_SOUND
		select_sound.play()
		
		music.stop()
		
		TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
		TransitionSystem.connect("transition_finished", self, "_switch_to_main_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _on_mod_name_pressed(mod_name: String, play_sound: bool = true):
	var mod_desc: ModDescription = mod_desc_map[mod_name]
	
	if mod_desc.banner:
		banner.material.set_shader_param("img", mod_desc.banner)
	else:
		banner.material.set_shader_param("img", DEFAULT_BANNER)
	
	author_info.text = mod_desc.mod_version + "\n" + mod_desc.mod_author
	description.parse_bbcode(mod_desc.description)
	
	if play_sound:
		select_sound.play()
	if launch_button.disabled:
		launch_button.disabled = false
	
	cur_option = mod_name

func _on_launch_pressed():
	for button in button_container.get_children():
		button.disabled = true
	launch_button.disabled = true
	music.get_node("AnimationPlayer").play("Fade_Out")
	
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
	yield(TransitionSystem, "transition_finished")
	
	var mod_desc: ModDescription = mod_desc_map[cur_option]
	
	if !(cur_option == "Base Benjine" || OS.has_feature("editor")):
		var mod_path = UserData.get_modpacks_path().plus_file(mod_desc.mod_package_name + ".pck")
		
		print("Loading advanced mod")
		var success = ProjectSettings.load_resource_pack(mod_path)
		print("Loading of advanced mod" + cur_option + " at " + mod_path + " successful?: " + str(success))
		
		if success:
			UserData.load_keybinds(package_name_map[cur_option])
	
	get_tree().change_scene(mod_desc.main_path)

func _switch_to_main_menu(_trans_name):
	get_parent().switch_state(MAIN_MENU)
