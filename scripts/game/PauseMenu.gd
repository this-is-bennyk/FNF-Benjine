extends "res://scripts/menus/FNFStyleMenu.gd"

func _create_text(idx):
	var new_text = FNF_STYLE_TEXT_BOLD.instance()
	
	new_text.text = options[idx]
	new_text.rect_global_position = get_option_position(idx - 1)
	
	new_text.modulate = Color(1, 1, 1, get_option_alpha(idx))
	
	get_node(container_path).add_child(new_text)
