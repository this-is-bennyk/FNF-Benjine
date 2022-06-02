extends Note

export(NodePath) var anim_sprite_nodepath = NodePath("AnimatedSprite")

export(String) var regular_note_anim
export(String) var sustain_line_anim
export(String) var sustain_cap_anim

onready var anim_sprite: AnimatedSprite = get_node(anim_sprite_nodepath)

func initialize_note():
	var anim_sprite_ref = get_node(anim_sprite_nodepath)
	
	if note_type == Type.SUSTAIN_LINE || note_type == Type.SUSTAIN_CAP:
		var anim_to_play = sustain_line_anim if note_type == Type.SUSTAIN_LINE else sustain_cap_anim
		
		anim_sprite_ref.modulate.a = 0.5
		anim_sprite_ref.play(anim_to_play)
	else:
		anim_sprite_ref.play(regular_note_anim)
		
		if UserData.get_setting("downscroll", 0, "gameplay"):
			anim_sprite_ref.rotation_degrees += 180
