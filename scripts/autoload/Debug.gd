extends Node

signal botplay_changed

var botplay = false

func _ready():
	set_process_input(OS.has_feature("debug"))

func _input(event):
	if event is InputEventKey && event.scancode == KEY_F4 && event.pressed:
		botplay = !botplay
		emit_signal("botplay_changed")
		print("Botplay is ", "enabled" if botplay else "disabled")
