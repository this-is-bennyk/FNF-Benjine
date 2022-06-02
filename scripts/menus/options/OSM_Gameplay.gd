extends "res://scripts/menus/options/OptionsSubmenu.gd"

##############################
# GAMEPLAY SPECIFIC CODE
##############################

onready var combo_adjustment = $"../../Combo_Adjustment"

##############################

func _ready():
	for option_path in valid_options_paths:
		get_node(option_path).reload()

##############################
# GAMEPLAY SPECIFIC CODE
##############################

func _process(delta):
	if !(Input.is_action_pressed("ui_left") || Input.is_action_pressed("ui_right")):
		return
	
	match options[cur_option].name:
		"Combo_X_Offset", "Combo_Y_Offset":
			combo_adjustment.show_adjustments()

##############################

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
	
	##############################
	# GAMEPLAY SPECIFIC CODE
	##############################
	
	match options[cur_option].name:
		"Fullscreen":
			OS.window_fullscreen = bool(UserData.get_setting("fullscreen", 0, "gameplay"))
	
	##############################
	
	if !_event.is_pressed():
		return
	
	match GodotX.get_script_filename(options[cur_option]):
		_: # SpinOption
			scroll_sound.stop()
			scroll_sound.play()
