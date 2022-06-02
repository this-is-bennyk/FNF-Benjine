extends Node

const OPTIONS = [
	"story mode",
	"freeplay",
	"credits",
	"options"
]

const MENUS = [
	"res://scenes/shared/menus/default_menus/StoryModeMenu.tscn",
	"res://scenes/shared/menus/default_menus/FreeplayMenu.tscn",
	"res://scenes/shared/menus/default_menus/CreditsMenu.tscn",
	"res://scenes/shared/menus/default_menus/OptionsMenu.tscn",
	"res://scenes/shared/menus/default_menus/TitleScreen.tscn"
]

const FREAKY_MENU = preload("res://assets/music/freakyMenu.ogg")
const CONFIRM_SOUND = preload("res://assets/sounds/confirmMenu.ogg")
const CANCEL_SOUND = preload("res://assets/sounds/cancelMenu.ogg")

export(NodePath) var menu_bg_path
export(NodePath) var options_list_path
export(NodePath) var story_mode_btn_path
export(NodePath) var freeplay_btn_path
export(NodePath) var credits_btn_path
export(NodePath) var options_btn_path
export(NodePath) var camera_path
export(NodePath) var position_path
export(NodePath) var menu_select_sound_path

onready var menu_bg = get_node(menu_bg_path)
onready var options_list = get_node(options_list_path)
onready var story_mode_btn = get_node(story_mode_btn_path)
onready var freeplay_btn = get_node(freeplay_btn_path)
onready var credits_btn = get_node(credits_btn_path)
onready var options_btn = get_node(options_btn_path)
onready var camera = get_node(camera_path)
onready var position = get_node(position_path)
onready var menu_select_sound = get_node(menu_select_sound_path)

var option_idx = 0

func _ready():
	on_ready()

func _process(delta):
	on_update(delta)

func _input(event):
	on_input(event)

func on_ready():
	var options_list_ref = get_node(options_list_path)
	var position_ref = get_node(position_path)
	var camera_ref = get_node(camera_path)
	
	position_ref.global_position = options_list_ref.get_child(option_idx).global_position
	camera_ref.follow_point = position_ref
	camera_ref.reset_position()
	
	for idx in options_list_ref.get_child_count():
		var suffix = " white" if idx == 0 else " basic"
		options_list_ref.get_child(idx).play(OPTIONS[idx] + suffix)
	
	if !Conductor.playing || Conductor.stream != FREAKY_MENU:
		Conductor.volume_db = linear2db(0.8)
		Conductor.play_music(FREAKY_MENU, 102)
	
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func on_update(delta):
	camera.on_update()

func on_input(event):
	if GodotX.xor(event.is_action_pressed("ui_up"), event.is_action_pressed("ui_down")):
		options_list.get_child(option_idx).play(OPTIONS[option_idx] + " basic")
		
		var increment = -1 if event.is_action_pressed("ui_up") else 1
		option_idx = wrapi(option_idx + increment, 0, 4)
		
		position.global_position = options_list.get_child(option_idx).global_position
		options_list.get_child(option_idx).play(OPTIONS[option_idx] + " white")
		
		menu_select_sound.stop()
		menu_select_sound.play()
		
	elif event.is_action_pressed("ui_accept"):
		set_process_input(false)
		
		if option_idx == 1 || option_idx == 3:
			Conductor.stop_song()
		
		menu_select_sound.stop()
		menu_select_sound.stream = CONFIRM_SOUND
		menu_select_sound.play()
		
		menu_bg.get_node("AnimationPlayer").play("Flicker")
		
		var timer = get_tree().create_timer(1)
		
		timer.connect("timeout", TransitionSystem, "play_transition", [TransitionSystem.Transitions.BASIC_FADE_OUT], CONNECT_DEFERRED | CONNECT_ONESHOT)
		timer.connect("timeout", TransitionSystem, "connect", ["transition_finished", self, "_switch_to_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT], CONNECT_DEFERRED | CONNECT_ONESHOT)
	
	elif event.is_action_released("ui_cancel"):
		set_process_input(false)
		
		option_idx = -1
		
		menu_select_sound.stop()
		menu_select_sound.stream = CANCEL_SOUND
		menu_select_sound.play()
		
		TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
		TransitionSystem.connect("transition_finished", self, "_switch_to_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _switch_to_menu(_trans_name):
	match option_idx:
		-1:
			get_parent().switch_state(load(MENUS[len(MENUS) - 1]), { "intro_skipped": true })
		0:
			get_parent().switch_state(MENUS[option_idx])
		_:
			get_parent().switch_state(load(MENUS[option_idx]))
