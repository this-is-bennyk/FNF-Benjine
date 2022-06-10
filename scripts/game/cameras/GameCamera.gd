extends "res://scripts/game/cameras/FollowerCamera.gd"

export(float) var zoom_on_quarter_hit = 0.715 # 65 for 3D cams

onready var beat_anim = $Cam_Zoom_Beat

var cur_performer = ""

func get_movement_lerp():
	return 0.08

func get_default_resting_zoom():
	return 0.7

func tween_zoom():
	tween.stop(self, "zoom_axis")
	tween.interpolate_method(
		self,
		"zoom_axis",
		zoom_on_quarter_hit,
		resting_zoom,
		Conductor.get_quarter_length() * 2 / Conductor.pitch_scale,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT)
	tween.start()
