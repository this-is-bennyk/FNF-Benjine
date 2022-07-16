extends "res://scripts/menus/options/OptionsSubmenu.gd"

const PACKAGE_TITLE = preload("res://scenes/shared/menus/options/PackageTitle.tscn")
const SPIN_OPTION = preload("res://scenes/shared/menus/options/SpinOption.tscn")

const SB_EMPTY = preload("res://assets/graphics/menus/SB_Empty.tres")
const SEPARATION = 10

const NO_MODS = "No modded options found."

func _ready():
	var dir = Directory.new()
	var packages = UserData.get_package_names()
	packages.erase("fnf")
	
	for package in packages:
		var default_options_path = UserData.get_options_path(package)
		
		if !dir.file_exists(default_options_path):
			continue
		
		var default_options = load(default_options_path)
		
		if get_child_count() > 0:
			var separator = HSeparator.new()
			
			separator.add_stylebox_override("separator", SB_EMPTY)
			separator.add_constant_override("separation", SEPARATION)
			
			add_child(separator)
		
		var title = PACKAGE_TITLE.instance()
		title.text = UserData.get_mod_desc(package).mod_name
		add_child(title)
		
		for option_entry in default_options.list:
			var spin_option = SPIN_OPTION.instance()
			
			spin_option.option_name = option_entry.option_name
			spin_option.option_package = package
			spin_option.options = option_entry.options
			spin_option.num_range = option_entry.num_range
			spin_option.num_range_min = option_entry.num_range_min
			spin_option.num_range_max = option_entry.num_range_max
			spin_option.default_option = option_entry.default_option
			
			if !option_entry.option_display_name.empty():
				spin_option.text = option_entry.option_display_name
			
			options.append(spin_option)
			add_child(spin_option)
	
	for option in options:
		option.reload()
	
	if get_child_count() == 0:
		var msg = PACKAGE_TITLE.instance()
		msg.text = NO_MODS
		add_child(msg)

func on_input(event: InputEvent):
	if GodotX.xor(event.is_action_released("ui_up"), event.is_action_released("ui_down")):
		var increment = -1 if event.is_action_released("ui_up") else 1
	
		cur_option = wrapi(cur_option + increment, 0, len(options))
		on_scroll()
	
	elif GodotX.xor(event.is_action("ui_left"), event.is_action("ui_right")):
		on_select(event)
	
	elif event.is_action_released("ui_cancel"):
		on_back()

func on_select(_event):
	options[cur_option].on_input(_event)
	
	if !_event.is_pressed():
		return
	
	match GodotX.get_script_filename(options[cur_option]):
		_: # SpinOption
			scroll_sound.stop()
			scroll_sound.play()
