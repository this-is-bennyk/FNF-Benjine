extends Node
class_name HealthIcon

const DEFAULT_END_TIME = 0.5

const DEFAULT_HTI_MAP = [
	{
		health = 1.0,
		index = 0
	},
	{
		health = 0.2,
		index = 1
	}
]

export(NodePath) var icon_path = "Icon"
export(Array, Dictionary) var health_to_index_map = DEFAULT_HTI_MAP

onready var icon = get_node_or_null(icon_path)

func change_icon(health_percent):
	if (!icon): return
	
	icon.frame = get_index_from_current_health(health_percent)

func get_index_from_current_health(health_percent):
	if !_is_player_icon():
		health_percent = 1.0 - health_percent
	
	var idx = health_to_index_map[0].index
	
	for health_idx_pair in health_to_index_map:
		if health_idx_pair.health > health_percent:
			idx = health_idx_pair.index
	
	return idx

func get_beat_anim_time():
	if !icon: return DEFAULT_END_TIME
	
	if !icon.anim_player.is_playing():
		return icon.anim_player.current_animation_length
	
	return icon.anim_player.current_animation_position

func set_beat_anim_time(time):
	if icon && icon.get("anim_player"):
		icon.play_anim("Idle")
		icon.anim_player.seek(time, true)

func _is_player_icon():
	return sign(get_parent().scale.x) == -1
