extends Node2D

onready var lane_type = get_child(0).lane_type

func _ready():
	_adjust_for_downscroll()
	_adjust_for_middlescroll()

func _adjust_for_downscroll():
	if !UserData.get_setting("downscroll", 0, "gameplay"):
		return
	
	position.y = 720 - position.y

func _adjust_for_middlescroll():
	if !UserData.get_setting("middlescroll", 0, "gameplay"):
		return
	
	if lane_type == Lane.Type.PLAYER:
		position.x = 1280 / 2
	else:
		hide()
