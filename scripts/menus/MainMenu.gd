extends Node

const OPTIONS = [
	"story mode",
	"freeplay",
	"mods",
	"credits",
	"options"
]

const MENUS = [
	"res://scenes/shared/menus/default_menus/StoryModeMenu.tscn",
	"res://scenes/shared/menus/default_menus/FreeplayMenu.tscn",
	"res://scenes/shared/menus/default_menus/ModsMenu.tscn",
	"res://scenes/shared/menus/default_menus/CreditsMenu.tscn",
	"res://scenes/shared/menus/default_menus/OptionsMenu.tscn",
	"res://scenes/shared/menus/default_menus/TitleScreen.tscn"
]

const FREAKY_MENU = preload("res://assets/music/freakyMenu.ogg")
const CONFIRM_SOUND = preload("res://assets/sounds/confirmMenu.ogg")
const CANCEL_SOUND = preload("res://assets/sounds/cancelMenu.ogg")

export(NodePath) var menu_bg_path
export(NodePath) var options_list_path
export(NodePath) var mod_type_path
export(NodePath) var camera_path
export(NodePath) var position_path
export(NodePath) var menu_select_sound_path

onready var menu_bg = get_node(menu_bg_path)
onready var options_list = get_node(options_list_path)
onready var mod_type = get_node(mod_type_path)
onready var camera = get_node(camera_path)
onready var position = get_node(position_path)
onready var menu_select_sound = get_node(menu_select_sound_path)

var option_idx = 0
var advanced_mods = false

func _ready():
	on_ready()

func _process(delta):
	on_update(delta)

func _input(event):
	on_input(event)

func on_ready():
	var options_list_ref = get_node(options_list_path)
	var mod_type_ref = get_node(mod_type_path)
	var position_ref = get_node(position_path)
	var camera_ref = get_node(camera_path)
	
	position_ref.global_position = options_list_ref.get_child(option_idx).global_position
	camera_ref.follow_point = position_ref
	camera_ref.reset_position()
	mod_type_ref.play()
	
	for idx in options_list_ref.get_child_count():
		var suffix = " white" if idx == 0 else " basic"
		options_list_ref.get_child(idx).play(OPTIONS[idx] + suffix)
		
		if idx == 2 && OS.get_name() == "HTML5":
			options_list_ref.get_child(idx).modulate = Color.dimgray
	
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
		option_idx = wrapi(option_idx + increment, 0, len(OPTIONS))
		
		position.global_position = options_list.get_child(option_idx).global_position
		options_list.get_child(option_idx).play(OPTIONS[option_idx] + " white")
		
		menu_select_sound.stop()
		menu_select_sound.play()
		
		if OS.get_name() == "HTML5":
			return
		
		if option_idx == 2:
			mod_type.show()
		else:
			mod_type.hide()
	
	elif option_idx == 2 && GodotX.xor(event.is_action_pressed("ui_left"), event.is_action_pressed("ui_right")):
		if OS.get_name() == "HTML5":
			return
		
		advanced_mods = !advanced_mods
		
		mod_type.get_node("Label").text = "[ADVANCED]" if advanced_mods else "[BASIC]"
		menu_select_sound.stop()
		menu_select_sound.play()
	
	elif event.is_action_pressed("ui_accept"):
		if option_idx == 2 && OS.get_name() == "HTML5":
			return
		
		set_process_input(false)
		
		if option_idx == 1 || option_idx == 2 || option_idx == 4:
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
		2:
			get_parent().switch_state(load(MENUS[option_idx]), {
				"advanced_mods": advanced_mods
			})
		_:
			get_parent().switch_state(load(MENUS[option_idx]))
