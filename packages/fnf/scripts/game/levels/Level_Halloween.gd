extends "res://scripts/game/Level.gd"

const THUNDER_SOUNDS = [
	preload("res://packages/fnf/resources/sounds/thunder_1.ogg"),
	preload("res://packages/fnf/resources/sounds/thunder_2.ogg")
]

onready var thunder = $Thunder
onready var lightning_anim = $BG/AnimationPlayer

func do_level_specific_prep():
	match song_data.name:
		"Monster":
			switch_performer("opponent", "monster")

func do_lightning_strike():
	if randf() <= 0.1:
		var remaining_quarter = float(Conductor.get_quarter(true) + 1) - Conductor.get_quarter(false)
		
		thunder.stop()
		thunder.stream = THUNDER_SOUNDS[randi() % 2]
		thunder.play()
		
		lightning_anim.stop()
		lightning_anim.play("Lightning")
		
		get_performer("player").play_anim("Fear", remaining_quarter)
		get_performer("metronome").play_anim("Fear", remaining_quarter)
