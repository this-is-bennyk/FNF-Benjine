extends "res://scripts/menus/options/OptionsSubmenu.gd"

func on_scroll():
	.on_scroll()
	
	for option in options:
		option.unprime()

func on_back():
	.on_back()
	
	for option in options:
		option.unprime()

func on_select(_event):
	.on_select(_event)
	
	options[cur_option].on_input(_event)
