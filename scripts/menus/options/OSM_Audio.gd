extends "res://scripts/menus/options/OptionsSubmenu.gd"

const AUDIO_BUSES = ["Master", "Music", "SFX"]

func _ready():
	for i in len(valid_options_paths):
		_reset_audio_level(i)

func on_input(event: InputEvent):
	if GodotX.xor(event.is_action_released("ui_up"), event.is_action_released("ui_down")):
		var increment = -1 if event.is_action_released("ui_up") else 1
	
		cur_option = wrapi(cur_option + increment, 0, len(options))
		on_scroll()
	
	elif GodotX.xor(event.is_action_released("ui_left"), event.is_action_released("ui_right")):
		on_select(event)
	
	elif event.is_action_released("ui_cancel"):
		on_back()

func on_select(_event):
	var increment = -1 if _event.is_action_released("ui_left") else 1
	
	var new_vol = int(clamp(UserData.get_setting(options[cur_option].name, 10, "audio") + increment, 0, 10))
	UserData.set_setting(options[cur_option].name, new_vol, "audio")
	
	_reset_audio_level(cur_option)
	_reset_bars(cur_option)
	
	options[cur_option].get_node("Audio_Level_Indicator").stop()
	options[cur_option].get_node("Audio_Level_Indicator").play()

func reset():
	.reset()
	
	for option_idx in len(options):
		_reset_audio_level(option_idx)
		_reset_bars(option_idx)

func _reset_audio_level(idx):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AUDIO_BUSES[idx]), linear2db(float(UserData.get_setting(AUDIO_BUSES[idx], 10, "audio")) / 10.0))

func _reset_bars(idx):
	var lvl = UserData.get_setting(options[idx].name, 10, "audio")
	var bars = options[idx].get_node("AudioBars").get_children()
	
	for bar_idx in len(bars):
		if bar_idx + 1 <= lvl:
			bars[bar_idx].color.a = 1.0
		else:
			bars[bar_idx].color.a = 0.25
