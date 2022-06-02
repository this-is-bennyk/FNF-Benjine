extends "res://scripts/game/characters/BeatNode.gd"

func play_anim(anim_data, anim_length = 0, forced = true, uninterruptable = false):
	.play_anim(anim_data, anim_length, forced)
	anim_player.playback_speed = Conductor.get_bpm() / 60.0 * Conductor.pitch_scale
