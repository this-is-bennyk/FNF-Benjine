extends Node

export(String) var offset_text_path = "res://"
export(String) var offset_file_path = "res://"

func _ready():
	yield(get_tree(), "idle_frame")
	var offset_text = File.new()
	
	offset_text.open(offset_text_path, File.READ)
	
	while (!offset_text.eof_reached()):
		var string = offset_text.get_line().split(" ")
		
