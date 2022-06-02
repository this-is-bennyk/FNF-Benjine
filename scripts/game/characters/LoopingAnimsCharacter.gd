extends "res://scripts/game/characters/Character.gd"

func play_anim(anim_data, anim_length = 0, forced = true, uninterruptable = false):
	var anim_name = get_anim_name(anim_data)
	
	if !(anim_name == anim_player.assigned_animation && anim_name in get_looping_anim_names()):
		.play_anim(anim_data, anim_length, forced, uninterruptable)
	
#	if anim_data is int:
#		anim_name = direction_anims[anim_data]
#	else: # data should be a String
#		anim_name = anim_data
#
#	anim_name = _swap_name_if_flipped(anim_name)
#
#	if anim_length:
#		anim_timer = anim_length
#
#	if !(anim_name == anim_player.assigned_animation && anim_name in get_looping_anim_names()):
#		if forced:
#			anim_player.stop()
#		anim_player.play(anim_name)

func get_looping_anim_names():
	return direction_anims.slice(4, 7)
