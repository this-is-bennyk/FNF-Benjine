extends Note

export(NodePath) var note_model_path = NodePath("Note")
export(NodePath) var sustain_line_model_path = NodePath("Sustain_Line")
export(NodePath) var sustain_cap_model_path = NodePath("Sustain_Cap")

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
	
	else:
		get_node(sustain_line_model_path).hide()
		get_node(sustain_cap_model_path).hide()
		
		model = get_node(note_model_path)
		
		if UserData.get_setting("downscroll", 0, "gameplay"):
			model.rotation_degrees.z += 180
