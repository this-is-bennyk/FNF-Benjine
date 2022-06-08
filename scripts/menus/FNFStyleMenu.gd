extends Node

signal option_changed(option_idx, option)
signal option_selected(option_idx, option)

const FNF_STYLE_TEXT_BOLD = preload("res://scenes/shared/menus/FNFStyleText_Bold.tscn")

export(NodePath) var selection_audio_path = NodePath("Selection_Audio")
export(NodePath) var container_path = NodePath("Options_Container")
export(Array, String) var options

onready var selection_audio = get_node(selection_audio_path)
onready var options_container = get_node(container_path)

var cur_selected = 0

func _ready():
	on_ready()

func _process(_delta):
	on_update()

func on_ready(play_audio = true):
	clear_options()
	
	for i in len(options):
		_create_text(i)
	
	if play_audio:
		get_node(selection_audio_path).play()

func on_input(event):
	if event.is_action_pressed("ui_up") || event.is_action_pressed("ui_down"):
		var increment = -1 if event.is_action("ui_up") else 1
		change_option(increment)
		selection_audio.play()
		_emit_changed()
		
	elif event.is_action_pressed("ui_accept"):
		_emit_selected()

func on_update():
	for i in options_container.get_child_count():
		var child = options_container.get_child(i)
		var idx_relative_to_selected = i - cur_selected
		
		update_option_position(child, idx_relative_to_selected)

func change_option(increment):
	cur_selected = wrapi(cur_selected + increment, 0, len(options))
	_update_alphas()

func change_option_to(idx):
	cur_selected = wrapi(idx, 0, len(options))
	_update_alphas()

func get_option_position(idx):
	var scaled_idx = range_lerp(idx, 0, 1, 0, 1.3)
	
	var new_x = (idx * 20) + 90
	var new_y = (scaled_idx * 120) + (GodotX.WINDOW_Y * 0.48)
	
	return Vector2(new_x, new_y)

func update_option_position(option, idx_relative_to_selected):
	option.rect_global_position = lerp(option.rect_global_position, get_option_position(idx_relative_to_selected), get_lerp_val())

func get_option_alpha(idx):
	if idx == 0:
		return 1
	else:
		return 0.6

func clear_options():
	for option in options_container.get_children():
		option.queue_free()
	
	cur_selected = 0

func disable_input():
	set_process_input(false)

func get_lerp_val():
	return GodotX.get_haxeflixel_lerp(0.3)

func _create_text(idx):
	var new_text = FNF_STYLE_TEXT_BOLD.instance()
	
	new_text.text = options[idx]
	new_text.rect_global_position = get_option_position(idx)
	new_text.call_deferred("force_update_transform")
	
	new_text.modulate.a = get_option_alpha(idx)
	
	get_node(container_path).add_child(new_text)

func _update_alphas():
	for i in options_container.get_child_count():
		var child = options_container.get_child(i)
		var idx_relative_to_selected = i - cur_selected
		
		child.modulate.a = get_option_alpha(idx_relative_to_selected)

func _emit_changed():
	emit_signal("option_changed", cur_selected, options[cur_selected])

func _emit_selected():
	emit_signal("option_selected", cur_selected, options[cur_selected])
