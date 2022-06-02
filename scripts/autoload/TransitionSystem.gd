extends CanvasLayer

signal transition_finished(transition_name)

enum Transitions {
	BASIC_FADE_IN,
	BASIC_FADE_OUT,
	SCREEN_CAP_IN,
	SCREEN_CAP_OUT
}

export(NodePath) var anim_player_path

onready var anim_player = get_node(anim_player_path)
onready var screen_capture = $Screen_Capture

func start_transition(transition_name):
	# TODO: Separate this into separate func
	match transition_name:
		"Screen_Cap_Out":
			var screen_tex = ImageTexture.new()
			screen_tex.create_from_image(get_viewport().get_texture().get_data())
			
			screen_capture.texture = screen_tex
			screen_capture.scale = Vector2(1280.0 / screen_tex.get_width(), 720.0 / screen_tex.get_height())
		"Screen_Cap_In":
			# BAD AND DANGEROUS
			# TODO: CAN WE PLEASE NOT DO THIS
			# TODO: DEBUG
			for _i in range(5): # 3 loading frames, 1 start defer, 1 to begin the countdown
				yield(get_tree(), "idle_frame")
	
	_play_anim(transition_name)

func play_transition(transition):
	if anim_player.is_connected("animation_finished", self, "_on_anim_finished"):
		anim_player.disconnect("animation_finished", self, "_on_anim_finished")
	
	match transition:
		Transitions.BASIC_FADE_IN:
			start_transition("Basic_Fade_In")
		Transitions.BASIC_FADE_OUT:
			start_transition("Basic_Fade_Out")
		Transitions.SCREEN_CAP_IN:
			start_transition("Screen_Cap_In")
		Transitions.SCREEN_CAP_OUT:
			start_transition("Screen_Cap_Out")

func reset():
	if anim_player.is_connected("animation_finished", self, "_on_anim_finished"):
		anim_player.disconnect("animation_finished", self, "_on_anim_finished")
	
	anim_player.stop()
	anim_player.play("RESET")

func _on_anim_finished(anim_name):
	emit_signal("transition_finished", anim_name)

func _play_anim(transition_name):
	anim_player.stop()
	anim_player.play(transition_name)
	anim_player.connect("animation_finished", self, "_on_anim_finished", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
