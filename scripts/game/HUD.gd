extends Node

const BAR_START_X = -296
const BAR_END_X = 296

var miss_sounds = [
	preload("res://assets/sounds/missnote1.ogg"),
	preload("res://assets/sounds/missnote2.ogg"),
	preload("res://assets/sounds/missnote3.ogg")
]

export(NodePath) var camera_path
export(NodePath) var ratings_list_path

export(NodePath) var visible_elements_path = NodePath("Visible_Elements")

export(NodePath) var player_health_path
export(NodePath) var opponent_health_path

export(NodePath) var player_health_icon_path
export(NodePath) var opponent_health_icon_path

export(NodePath) var score_text_path

export(NodePath) var countdown_path
export(NodePath) var countdown_msgs_path
export(NodePath) var countdown_tween_path

export(NodePath) var miss_sound_player_path

export(NodePath) var tween_path = NodePath("Tween")

export(NodePath) var beat_anim_path

export(float) var resting_zoom = 1
export(float) var zoom_on_quarter_hit = 1.03

onready var camera = get_node(camera_path)
onready var ratings_list = get_node(ratings_list_path)

onready var visible_elements = get_node(visible_elements_path)

onready var player_health_bar = get_node(player_health_path)
onready var opponent_health_bar = get_node(opponent_health_path)

onready var player_health_icon = get_node(player_health_icon_path)
onready var opponent_health_icon = get_node(opponent_health_icon_path)

onready var score_text = get_node(score_text_path)

onready var countdown = get_node(countdown_path)
onready var countdown_msgs = get_node(countdown_msgs_path)
onready var countdown_tween = get_node(countdown_tween_path)

onready var miss_sound_player = get_node(miss_sound_player_path)

onready var tween = get_node(tween_path)

onready var beat_anim = get_node(beat_anim_path)

func update_health(cur_health_percent):
	var new_health_x = lerp(BAR_START_X, BAR_END_X, 1 - cur_health_percent)
	
	update_icons(cur_health_percent)
	
	player_health_bar.points[0].x = new_health_x
	opponent_health_bar.points[1].x = new_health_x
	
	player_health_icon.position.x = new_health_x
	opponent_health_icon.position.x = new_health_x

# TODO: Refactor icons to not depend on child 0

func update_icons(cur_health_percent):
	if player_health_icon.get_child_count() > 0:
		var actual_icon = player_health_icon.get_child(0)
		
		if actual_icon is HealthIcon:
			actual_icon.change_icon(cur_health_percent)
	
	if opponent_health_icon.get_child_count() > 0:
		var actual_icon = opponent_health_icon.get_child(0)
		
		if actual_icon is HealthIcon:
			actual_icon.change_icon(cur_health_percent)

func update_score(score, misses, rating, percent):
	if Debug.botplay:
		score_text.text = "BOTPLAY"
		return
	
	var new_text = "Score: " + str(score) + " | Misses: " + str(misses) + " | Accuracy: " + rating
	
	if percent == -1:
		new_text += " (--%)"
	else:
		new_text += " (" + str(percent) + "%)"
	
	score_text.text = new_text

#func update_zoom():
#	if !zoom_overriden():
#		transform_assist.scale = lerp(transform_assist.scale, Vector2(get_resting_zoom(), get_resting_zoom()), GodotX.get_haxeflixel_lerp(get_zoom_lerp()))
#		transform_assist.update_hud_transform()

#func zoom_overriden():
#	return NodePath("../../Transform_Assist:scale") in camera.tweening_properties

#func get_resting_zoom():
#	return get_default_resting_zoom()
#
#func get_default_resting_zoom():
#	return 1

#func get_zoom_lerp():
#	return get_default_zoom_lerp()
#
#func get_default_zoom_lerp():
#	return 0.95

#func get_zoom_on_quarter_hit():
#	return get_resting_zoom() + 0.03

func play_miss_sound():
	miss_sound_player.stop()
	miss_sound_player.stream = miss_sounds[randi() % len(miss_sounds)]
	miss_sound_player.volume_db = linear2db(rand_range(0.1, 0.2))
	miss_sound_player.play()

func stop_miss_sound():
	miss_sound_player.stop()

func tween_zoom():
#	hud.transform_assist.scale = Vector2(hud.get_zoom_on_quarter_hit(), hud.get_zoom_on_quarter_hit())
#	hud.transform_assist.update_hud_transform()
	tween.stop(self, "scale")
	tween.interpolate_property(
		self,
		"scale",
		Vector2(zoom_on_quarter_hit, zoom_on_quarter_hit),
		Vector2(resting_zoom, resting_zoom),
		Conductor.get_quarter_length() * 2 / Conductor.pitch_scale,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT)
	tween.start()
