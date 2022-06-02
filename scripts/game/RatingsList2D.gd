extends Node2D

func _ready():
	_adjust_for_combo_offsets()

func _adjust_for_combo_offsets():
	position.x += UserData.get_setting("combo_x_offset", 0, "gameplay")
	position.y += UserData.get_setting("combo_y_offset", 0, "gameplay")
