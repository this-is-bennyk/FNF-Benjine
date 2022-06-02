extends "res://scripts/menus/options/OptionsSubmenu.gd"

const CONTROLS_PACK_TITLE = preload("res://scenes/shared/menus/options/CtrlPckTitle.tscn")
const KEYBIND_OPTION = preload("res://scenes/shared/menus/options/KeybindOption.tscn")

# We could make an on_ready function but I'm lazy lol
func _ready():
	var packages = UserData.get_package_names()
	
	packages.erase("fnf")
	packages.append("general")
	
	for package in packages:
		var actions = UserData.get_settings_in_category("input", package)
		var action_names = UserData.get_setting("order", [], "input", package)
		
		if !actions || actions.empty():
			continue
		
		##################################################
		
		var title = CONTROLS_PACK_TITLE.instance()
		
		if package == "general":
			title.text = "Base Controls"
		else:
			title.text = UserData.get_mod_desc(package).mod_name
		
		for action_name in action_names:
			if package == "general" && action_name == "bind_key":
				continue
			
			var input = actions[action_name]
			var keybinder = KEYBIND_OPTION.instance()
			
			keybinder.action_package = package
			keybinder.action_name = action_name
			keybinder.action_input = input
			
			options.append(keybinder)
			
			add_child(keybinder)

func on_input(event: InputEvent):
	if GodotX.xor(event.is_action_released("ui_up"), event.is_action_released("ui_down")) && !options[cur_option].binding:
		var increment = -1 if event.is_action_released("ui_up") else 1
		
		cur_option = wrapi(cur_option + increment, 0, len(options))
		
		on_scroll()
	
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
