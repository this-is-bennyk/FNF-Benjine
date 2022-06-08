tool
extends Node2D

export(StyleBoxTexture) var sustain_line: StyleBoxTexture setget set_sus_line
export(float, 0, 1) var percent_length: float = 1 setget set_percent
export(float) var total_length: float setget set_total_length

func set_sus_line(val):
	sustain_line = val
	update()

func set_percent(val):
	percent_length = val
	update()

func set_total_length(val):
	total_length = val
	update()

func _draw():
	if !sustain_line:
		return
	
	var pos = Vector2(-sustain_line.region_rect.size.x / 2.0, 0)
	var size = Vector2(sustain_line.region_rect.size.x, total_length * percent_length)
	
	draw_style_box(sustain_line, Rect2(pos, size))
