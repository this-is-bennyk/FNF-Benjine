extends "res://scripts/game/Level.gd"

# This level too, this level sucks

func set_preload_variables():
	countdown_voices = [
		preload("res://assets/sounds/introGo-pixel.ogg"),
		preload("res://assets/sounds/intro1-pixel.ogg"),
		preload("res://assets/sounds/intro2-pixel.ogg"),
		preload("res://assets/sounds/intro3-pixel.ogg")
	]
	
	popup_combo = preload("res://scenes/shared/game/PopupCombo_Pixel.tscn")
	
	miss_sounds = [
		preload("res://assets/sounds/missnote1.ogg"),
		preload("res://assets/sounds/missnote2.ogg"),
		preload("res://assets/sounds/missnote3.ogg")
	]

onready var evil_school = $ParallaxBackground/Evil_School/Evil_School

func do_level_specific_prep():
	evil_school.play("background 2 instance 1")

func do_pre_level_story_event():
	var new_dialogue = null
	
	match song_data.name:
		"Thorns":
			new_dialogue = Dialogic.start("FNF_Thorns")
	
	if new_dialogue:
		new_dialogue.connect("timeline_end", self, "_after_textbox", [], CONNECT_ONESHOT | CONNECT_DEFERRED)
		add_child(new_dialogue)
	else:
		start_level_part_2()

func _after_textbox(_tl_name):
	start_level_part_2()
