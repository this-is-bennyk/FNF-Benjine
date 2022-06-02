extends Node2D

onready var tween = $Tween
onready var combo_pos = $Combo_Pos

func show_adjustments():
	combo_pos.position.x = UserData.get_setting("combo_x_offset", 0, "gameplay")
	combo_pos.position.y = UserData.get_setting("combo_y_offset", 0, "gameplay")
	
	modulate.a = 1.0
	
	tween.stop_all()
	tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1.0)
	tween.start()
