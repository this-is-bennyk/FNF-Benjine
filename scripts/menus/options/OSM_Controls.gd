extends "res://scripts/menus/options/OptionsSubmenu.gd"

const BENJINE_KEYBINDS = preload("res://assets/data/benjine_keybinds.tres")

const PACKAGE_TITLE = preload("res://scenes/shared/menus/options/PackageTitle.tscn")
const KEYBIND_OPTION = preload("res://scenes/shared/menus/options/KeybindOption.tscn")

const SB_EMPTY = preload("res://assets/graphics/menus/SB_Empty.tres")
const SEPARATION = 10

var on_first_input = true

# We could make an on_ready function but I'm lazy lol
func _ready():
	var packages = UserData.get_package_names()
	
	packages.erase("fnf")
	packages.push_front("general")
	
	for package in packages:
		var default_actions = BENJINE_KEYBINDS
		
		if package != "general":
			var dir = Directory.new()
			var keybinds_path = UserData.get_keybinds_path(package)
			
			if !dir.file_exists(keybinds_path):
				continue
			
			default_actions = load(keybinds_path)
		
		##################################################
		
		var actions = UserData.get_settings_in_category("input", package)
		var title = PACKAGE_TITLE.instance()
		
		if package == "general":
			title.text = "Base Controls"
		else:
			title.text = UserData.get_mod_desc(package).mod_name
			
			var separator = HSeparator.new()
			
			separator.add_stylebox_override("separator", SB_EMPTY)
			separator.add_constant_override("separation", SEPARATION)
			
			add_child(separator)
		
		add_child(title)
		
		for keybind_entry in default_actions.list:
			var evs = actions[keybind_entry.action_name]
			var keybinder = KEYBIND_OPTION.instance()

			keybinder.action_package = package
			keybinder.action_name = keybind_entry.action_name
			keybinder.input1 = evs[0]
			keybinder.input2 = evs[1]

			options.append(keybinder)

			add_child(keybinder)

func on_input(event: InputEvent):
	if GodotX.xor(event.is_action_released("ui_up"), event.is_action_released("ui_down")) && !options[cur_option].binding:
		var increment = -1 if event.is_action_released("ui_up") else 1
		
		cur_option = wrapi(cur_option + increment, 0, len(options))
		
		on_scroll()
	
	elif GodotX.xor(event.is_action_released("ui_left"), event.is_action_released("ui_right")) && !options[cur_option].binding:
		on_first_input = !on_first_input
		
		for option in options:
			option.set_current_input_display(on_first_input)
			
		scroll_sound.stop()
		scroll_sound.play()
	
	elif event.is_action_released("ui_cancel") && !options[cur_option].binding:
		on_back()
	
	elif (event is InputEventKey || event is InputEventJoypadButton) && !event.is_pressed():
		on_select(event)

func on_select(_event):
	if !options[cur_option].binding:
		if _event.is_action_released("bind_key"):
			options[cur_option].on_input(_event)
			
			scroll_sound.stop()
			scroll_sound.play()
		
	elif !_event.is_pressed():
		options[cur_option].on_input(_event)
		
		if _event.is_action_released("ui_cancel"):
			back_sound.stop()
			back_sound.play()
		else:
			confirm_sound.stop()
			confirm_sound.play()
