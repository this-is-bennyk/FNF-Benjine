extends "res://scripts/game/characters/BeatNode.gd"

export(Array) var direction_anims: Array = ["Left", "Down", "Up", "Right"]

export(Array) var anim_pairs_if_flipped: Array = [
	["Left", "Right"],
	["Left_Miss", "Right_Miss"],
]

export(NodePath) var camera_follow_point_path = NodePath("Camera_Point")

export(PackedScene) var icon = preload("res://scenes/shared/game/icons/BF_Icon.tscn")

onready var camera_follow_point = get_node(camera_follow_point_path)

func play_anim(anim_data, anim_length = 0, forced = true, uninterruptable = false):
	.play_anim(get_anim_name(anim_data), anim_length, forced, uninterruptable)

func play_anim_for_quarters(anim_data, quarters = 0, seconds = 0, forced = true, uninterruptable = false):
	play_anim(anim_data, Conductor.get_seconds_per_beat() * quarters + seconds, forced, uninterruptable)

func get_anim_name(anim_data):
	var anim_name
	
	if anim_data is int:
		anim_name = direction_anims[anim_data]
	else: # data should be a String
		anim_name = anim_data
	
	anim_name = _swap_name_if_flipped(anim_name)
	
	return anim_name

func _swap_name_if_flipped(anim_name):
	if _flipped():
		for pair in anim_pairs_if_flipped:
			if anim_name in pair:
				if pair[0] == anim_name:
					return pair[1]
				return pair[0]
	return anim_name

func _flipped():
	var this = get_parent().get_node(name)
	
	return sign(this.scale.x) == -1 || \
		   (abs(this.rotation_degrees) == 180 && sign(this.scale.y) == -1)
