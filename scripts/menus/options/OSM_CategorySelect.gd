extends "res://scripts/menus/options/OptionsSubmenu.gd"

func on_select(_event):
	options_ui.change_menu(cur_option + 1)
	.on_select(_event)

func reset():
	pass

func on_back():
	options_ui.exit()
