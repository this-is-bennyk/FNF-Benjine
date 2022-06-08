extends "res://scripts/game/Level.gd"

onready var gf_layer = $ParallaxBackground/GF

func do_level_specific_prep():
	match song_data.name:
		"Tutorial":
			switch_performer("opponent", "gf")
			
			# TODO: Figure out why the fuck the above call
			# to switch_performer persists across scene instances
			# EDIT: it's a Godot bug
#			get_character("dad").hide()
			
			set_performer("metronome") # Clear metronome
			
			gf_layer.motion_scale = Vector2.ONE
		
		"Fresh", "Dadbattle":
			get_performer("player").idle_frequency = 2
			get_performer("opponent").idle_frequency = 2
