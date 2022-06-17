extends Note

export(NodePath) var note_model_path = NodePath("Note")
export(NodePath) var sustain_line_model_path = NodePath("Sustain_Line")
export(NodePath) var sustain_cap_model_path = NodePath("Sustain_Cap")
export(NodePath) var tween_nodepath = NodePath("Tween")

onready var tween: Tween = get_node(tween_nodepath)

onready var last_known_scroll_speed = Conductor.scroll_speed

var model

func initialize_note():
	if note_type == Type.SUSTAIN_LINE || note_type == Type.SUSTAIN_CAP:
		get_node(note_model_path).hide()
		
		if note_type == Type.SUSTAIN_LINE:
			get_node(sustain_cap_model_path).hide()
			model = get_node(sustain_line_model_path)
		else:
			get_node(sustain_line_model_path).hide()
			model = get_node(sustain_cap_model_path)
		
		_update_sustain_length()
	
	else:
		get_node(sustain_line_model_path).hide()
		get_node(sustain_cap_model_path).hide()
		
		model = get_node(note_model_path)
		
		if UserData.get_setting("downscroll", 0, "gameplay"):
			model.rotation_degrees.z += 180

func do_hit_action(lvl, dir, lane_type_string: String):
	do_action(lvl, dir, lane_type_string, HIT_PREFIX)
	
	if note_type == Type.REGULAR:
		queue_free()
	else: 
		if Conductor.event_position > strum_time + Conductor.get_sixteenth_length():
			queue_free()
			return
		
		var remaining_percent = inverse_lerp(Conductor.event_position - Conductor.get_sixteenth_length(), Conductor.event_position, strum_time)
		var remaining_time = Conductor.get_sixteenth_length() / Conductor.pitch_scale * remaining_percent
		
		tween.interpolate_property(model, "scale:y", model.scale.y * remaining_percent, 0, remaining_time)
		tween.connect("tween_all_completed", self, "queue_free", [], CONNECT_ONESHOT)
		tween.start()

func _process(_delta):
	on_update()

func on_update():
	if last_known_scroll_speed != Conductor.scroll_speed:
		_update_sustain_length()
		last_known_scroll_speed = Conductor.scroll_speed

func _update_sustain_length():
	var path_curve: Curve3D = get_parent().curve
	var multiplier = Conductor.get_sixteenth_length() / Conductor.SPAWN_TIME_CONSTANT * Conductor.scroll_speed
	
	model.scale.y = path_curve.get_baked_length() * multiplier
