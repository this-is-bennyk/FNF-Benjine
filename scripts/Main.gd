extends "res://scripts/general/StateManager.gd"

func _ready():
	randomize()
	switch_state(preload("res://scenes/shared/menus/ModLoader.tscn"))
