extends Node

static func get_frame_midpoint(anim_sprite: AnimatedSprite, anim_name, frame_num):
	var texture = anim_sprite.frames.get_frame(anim_name, frame_num)
	return texture.get_size() / 2.0

static func get_current_midpoint(anim_sprite: AnimatedSprite):
	return get_frame_midpoint(anim_sprite, anim_sprite.animation, anim_sprite.frame)
