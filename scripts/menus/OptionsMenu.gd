extends Node

const MAIN_MENU = preload("res://scenes/shared/menus/default_menus/MainMenu.tscn")

const OPTIONS_UI_PATH = NodePath("OptionsUI")

func _ready():
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func _input(event):
	var options_ui = get_node_or_null(OPTIONS_UI_PATH)
	
	if options_ui:
		options_ui.on_input(event)

func handle_options_exit():
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
	TransitionSystem.connect("transition_finished", self, "_switch_to_main_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _switch_to_main_menu(_trans_name):
	get_parent().switch_state(MAIN_MENU)
