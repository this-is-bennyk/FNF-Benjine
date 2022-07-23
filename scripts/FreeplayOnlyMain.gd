extends "res://scripts/general/StateManager.gd"

const FREEPLAY_MENU = preload("res://scenes/shared/menus/default_menus/FreeplayMenu.tscn")

export(PackedScene) var alt_freeplay = null
export(bool) var quit = true
export(String) var package_name
export(String, DIR) var prev_menu_path 
export(bool) var immediate_load = true

func _ready():
	randomize()
	if alt_freeplay:
		switch_state(alt_freeplay, {
			"freeplay_list": UserData.get_freeplay_list(package_name),
			"prev_menu_path": "QUIT" if quit else prev_menu_path
		})
	else:
		switch_state(FREEPLAY_MENU, {
			"freeplay_list": UserData.get_freeplay_list(package_name),
			"prev_menu_path": "QUIT" if quit else prev_menu_path
		})
