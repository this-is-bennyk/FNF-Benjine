extends "res://scripts/game/Level.gd"

onready var foliage = $ParallaxBackground/Tree_Tops/Foliage
onready var petals = $ParallaxBackground/Tree_Tops/Petals
onready var fangirls = $ParallaxBackground/Fangirls/Fangirls

# Man fuck this level
# It's cool as shit but idk what kinda devil magic NM put in it
# bc I can't replicate it 100%
# oh well it's pedantic anyways

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

func do_level_specific_prep():
	foliage.play("default")
	petals.play("PETALS ALL")
	
	if lvl_manager.is_freeplay:
		match song_data.name:
			"Roses":
				_change_to_roses()

func do_pre_level_story_event():
	var new_dialogue = null
	
	match song_data.name:
		"Senpai":
			new_dialogue = Dialogic.start("FNF_Senpai")
		"Roses":
			new_dialogue = Dialogic.start("FNF_Roses")
			
			_change_to_roses()
			get_performer("opponent").idle()
			fangirls.idle()
	
	if new_dialogue:
		new_dialogue.connect("timeline_end", self, "_after_textbox", [], CONNECT_ONESHOT | CONNECT_DEFERRED)
		add_child(new_dialogue)
	else:
		start_level_part_2()

func _after_textbox(_tl_name):
	start_level_part_2()

func _change_to_roses():
	var opponent = get_performer("opponent")
	
	opponent.idle_frequency = 2
	opponent.current_suffix = 1 # Angry
	opponent.on_ready()

	switch_icons("opponent", "opponent")

	fangirls.first_idle = "Distress_Up"
	fangirls.second_idle = "Distress_Down"
