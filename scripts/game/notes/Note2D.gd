extends Note

export(NodePath) var anim_sprite_nodepath = NodePath("AnimatedSprite")
export(NodePath) var sustain_nodepath = NodePath("Sustain")
export(NodePath) var tween_nodepath = NodePath("Tween")

export(StyleBoxTexture) var sustain_line_stylebox
export(StyleBoxTexture) var sustain_cap_stylebox

onready var anim_sprite: AnimatedSprite = get_node(anim_sprite_nodepath)
onready var sustain = get_node(sustain_nodepath)
onready var tween: Tween = get_node(tween_nodepath)

onready var last_known_scroll_speed = Conductor.scroll_speed

func initialize_note():
	if note_type == Type.SUSTAIN_LINE || note_type == Type.SUSTAIN_CAP:
		var sustain_ref = get_node(sustain_nodepath)
		get_node(anim_sprite_nodepath).hide()
		
		sustain_ref.sustain_line = sustain_line_stylebox if note_type == Type.SUSTAIN_LINE else sustain_cap_stylebox
		_update_sustain_length(sustain_ref)
	else:
		var anim_sprite_ref = get_node(anim_sprite_nodepath)
		get_node(sustain_nodepath).hide()
		
		anim_sprite_ref.play()
		
		if UserData.get_setting("downscroll", 0, "gameplay"):
			anim_sprite_ref.rotation_degrees += 180

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
		
		tween.interpolate_property(sustain, "percent_length", remaining_percent, 0, remaining_time)
		tween.connect("tween_all_completed", self, "queue_free", [], CONNECT_ONESHOT)
		tween.start()

func _process(_delta):
	on_update()

func on_update():
	if last_known_scroll_speed != Conductor.scroll_speed:
		_update_sustain_length()
		last_known_scroll_speed = Conductor.scroll_speed

func _update_sustain_length(sustain_ref = null):
	var sus = sustain_ref if sustain_ref else sustain
	var path_curve: Curve2D = get_parent().curve
	var multiplier = Conductor.get_sixteenth_length() / Conductor.SPAWN_TIME_CONSTANT * Conductor.scroll_speed
	
	sus.total_length = (path_curve.get_baked_length() * multiplier) / sus.scale.y
