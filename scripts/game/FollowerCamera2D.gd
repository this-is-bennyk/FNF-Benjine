extends Camera2D

export(NodePath) var tween_path = NodePath("Tween")
export(float) var resting_zoom = 0.7

onready var tween = get_node(tween_path)

var follow_point: Position2D

var tweening_properties = []

var custom_position = null

func _ready():
	on_ready()

func on_ready():
	get_node(tween_path).connect("tween_started", self, "_on_cam_tween_started")
	get_node(tween_path).connect("tween_completed", self, "_on_cam_tween_completed")

func on_update():
	update_movement()
#	update_zoom()

func update_movement():
	if !movement_overriden():
		global_position = lerp(global_position, get_position_to_follow(), GodotX.get_haxeflixel_lerp(get_movement_lerp()))

func get_movement_lerp():
	return get_default_movement_lerp()

func get_default_movement_lerp():
	return 1

func get_position_to_follow():
	if custom_position:
		return custom_position.global_position
	return follow_point.global_position

func reset_position(different_pos = null):
	if different_pos is Vector2:
		global_position = different_pos
	else:
		global_position = get_position_to_follow()

func reset_zoom(different_zoom = null):
	if different_zoom is float:
		zoom_axis(different_zoom)
	else:
		zoom_axis(resting_zoom)

func movement_overriden():
	return NodePath(":global_position") in tweening_properties

# TODO: Revert back to tweening, this shit sucks lmao
#func update_zoom():
#	if !zoom_overriden():
#		zoom_axis(lerp(1.0 / zoom.x, 1.0 / get_resting_zoom(), GodotX.get_haxeflixel_lerp(get_zoom_lerp())), 0, false)

#func get_resting_zoom():
#	if custom_resting_zoom:
#		return custom_resting_zoom
#	return get_default_resting_zoom()
#
#func get_default_resting_zoom():
#	return 1

#func get_zoom_lerp():
#	return get_default_zoom_lerp()
#
#func get_default_zoom_lerp():
#	return 0.95

func zoom_axis(val, axis = 0, fnf_val = true):
	val = 1.0 / val if fnf_val else val
	
	match axis:
		1:
			zoom = Vector2(val, zoom.y)
		2:
			zoom = Vector2(zoom.x, val)
		_:
			zoom = Vector2(val, val)

#func zoom_overriden():
#	return NodePath(":zoom") in tweening_properties

func _on_cam_tween_started(obj: Object, key: NodePath):
	if obj == self:
		tweening_properties.append(key)

func _on_cam_tween_completed(obj: Object, key: NodePath):
	if obj == self:
		tweening_properties.erase(key)
