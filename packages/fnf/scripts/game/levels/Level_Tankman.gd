extends "res://scripts/game/Level.gd"

# Yes this entire level is guesswork
# Week 7 source is still not out as of 3.4.2022 (mm.dd.yyyy)

const STRESS_P_GOOD_TIME = 62022.4727

onready var partners = $Partners
onready var w7_gf = $ParallaxBackground/Metronomes/W7_GF
onready var pico_speaker = $ParallaxBackground/Metronomes/Pico_Speaker

onready var tank_pathfollow = $ParallaxBackground/Behind_Ground/Tank_Path/Tank_PathFollow
onready var tank_tween = $ParallaxBackground/Behind_Ground/Tank_Path/Tank_PathFollow/Tween

func do_level_specific_prep():
	match song_data.name:
		"Stress":
			switch_performer("player", "partners")

			get_performer("metronome").hide()
			set_performer("metronome") # Clear metronome

			pico_speaker.show()

func hit_note_ugh_opponent(_dir, strum_time):
	hit_note_cpu("opponent", "Ugh", strum_time)

func hit_note_pretty_good_opponent(_dir, _strum_time):
	# The animation lasts 8 beats, but we're doing 9 for good measure (will be interrupted)
	get_performer("opponent").play_anim_for_quarters("Pretty_Good", 9, 0)
	Conductor.vocals.volume_db = 0

func roll_tank():
	tank_tween.interpolate_property(
		tank_pathfollow,
		"unit_offset",
		0,
		1,
		Conductor.get_seconds_per_beat() * 8 * 4 / Conductor.pitch_scale
	)
	
	tank_tween.start()
