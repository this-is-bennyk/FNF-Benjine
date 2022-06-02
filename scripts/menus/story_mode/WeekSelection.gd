extends "res://scripts/menus/FNFStyleMenu.gd"

const WEEK_OPTION = preload("res://scenes/shared/menus/story_menu/WeekOption.tscn")

func on_ready(play_audio = true):
	clear_options()
	
	for i in len(options):
		_create_week_option(i)
	
	if play_audio:
		get_node(selection_audio_path).play()

func get_option_position(idx):
	return Vector2(640, (idx * 120) + 517)

func update_option_position(option, idx_relative_to_selected):
	option.global_position = lerp(option.global_position, get_option_position(idx_relative_to_selected), get_lerp_val())

func get_lerp_val():
	return GodotX.get_haxeflixel_lerp(0.17)

func _create_week_option(idx):
	var week_option = WEEK_OPTION.instance()
	
	week_option.texture = options[idx]
	week_option.global_position = get_option_position(idx)
	week_option.call_deferred("force_update_transform")
	
	week_option.modulate.a = get_option_alpha(idx)
	
	get_node(container_path).add_child(week_option)

func _emit_changed():
	emit_signal("option_changed", cur_selected, null)

func _emit_selected():
	emit_signal("option_selected", cur_selected, null)
