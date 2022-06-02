tool
extends Node2D

enum HorizAlign { LEFT, CENTER, RIGHT }
enum VertAlign { TOP, MIDDLE }

export(String) var text setget on_text_changed
export(Font) var font setget on_font_changed
export(Color) var color = Color.white setget on_color_changed
export(HorizAlign) var h_align setget on_h_align_changed
export(VertAlign) var v_align setget on_v_align_changed

func on_text_changed(new_text):
	text = new_text
	update()

func on_font_changed(new_font):
	font = new_font
	update()

func on_color_changed(new_color):
	color = new_color
	update()

func on_h_align_changed(new_h_align):
	h_align = new_h_align
	update()

func on_v_align_changed(new_v_align):
	v_align = new_v_align
	update()

func _draw():
	var default_font = Control.new().get_font("font")
	var font_to_use = font if font else default_font
	var text_position = Vector2()
	var text_size = font.get_string_size(text)
	
	match h_align:
		HorizAlign.LEFT:
			text_position.x = 0
		HorizAlign.CENTER:
			text_position.x = -text_size.x / 2.0
		HorizAlign.RIGHT:
			text_position.x = -text_size.x
		_:
			text_position.x = 0
	
	match v_align:
		VertAlign.TOP:
			text_position.y = 0
		VertAlign.MIDDLE:
			text_position.y = font.get_ascent() / 2.0
		_:
			text_position.y = 0
	
	draw_string(font_to_use, text_position, text, color)
