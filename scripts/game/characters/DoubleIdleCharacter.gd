extends "res://scripts/game/characters/Character.gd"

export(String) var first_idle = "Dance_Left"
export(String) var second_idle = "Dance_Right"

export(bool) var starts_on_left = true

var danced_right = true

func on_ready():
	danced_right = starts_on_left
	.on_ready()

func idle():
	if danced_right:
		play_anim(first_idle)
	else:
		play_anim(second_idle)
	
	danced_right = !danced_right
