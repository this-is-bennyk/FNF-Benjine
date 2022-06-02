extends "res://scripts/game/Level.gd"

onready var stage_cam = $Stage_VP/GameCamera

func initialize_camera():
	.initialize_camera()
	
	stage_cam.follow_point = get_performer("player").camera_follow_point
	stage_cam.reset_position()
	stage_cam.reset_zoom()

func on_update(delta):
	.on_update(delta)
	
	if dying:
		return
	
	stage_cam.on_update()
