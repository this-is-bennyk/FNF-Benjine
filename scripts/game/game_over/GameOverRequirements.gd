extends Reference

func get_requirements(lvl):
	var player = lvl.get_performer("player")
	return {
		"cam_pos_from_level": lvl.hud.camera.global_position,
		"zoom_from_level": lvl.hud.camera.zoom,
		"player_pos_from_level": player.position,
		"player_scale_from_level": player.scale
	}
