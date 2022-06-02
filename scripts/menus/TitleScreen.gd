extends Node

const MAIN_MENU = preload("res://scenes/shared/menus/default_menus/MainMenu.tscn")
const FREAKY_MENU = preload("res://assets/music/freakyMenu.ogg")
const INTRO_SEQUENCE_QUARTERS = [3, 4, 5, 7, 8, 9, 11, 12, 13, 14, 15, 16]

onready var intro_sequence = $Intro_Sequence
onready var gf = $GF
onready var logo = $BenjineLogo
onready var press_enter = $Press_Enter
onready var flash = $Flash
onready var confirm_sound = $Confirm_Sound

onready var funny_text1 = $Intro_Part3/Text
onready var funny_text2 = $Intro_Part3/Text2

var intro_skipped = false
var cur_intro_part = 2

func _ready():
	if intro_skipped:
		if !Conductor.playing || Conductor.stream != FREAKY_MENU:
			Conductor.volume_db = linear2db(0.7)
			Conductor.play_music(FREAKY_MENU, 102)
		
		_skip_intro()
	else:
		var intro_text: Dictionary = UserData.load_data("res://assets/data/intro_texts.data")
		var random_entry_idx = randi() % intro_text.size()
		var random_entry = intro_text.keys()[random_entry_idx]
		
		funny_text1.text = random_entry
		funny_text2.text = "\n" + intro_text[random_entry]
		
		gf.hide()
		logo.hide()
		press_enter.hide()
		
		Conductor.volume_db = linear2db(0.7)
		Conductor.play_music(FREAKY_MENU, 102)
		Conductor.connect("quarter_hit", self, "_on_quarter_hit")
		
		intro_sequence.play("Part1")
	
	TransitionSystem.reset()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if intro_skipped:
			set_process_input(false)
			
			press_enter.get_node("AnimationPlayer").play("Flash")
			confirm_sound.play()
			
			var timer = get_tree().create_timer(1)
			timer.connect("timeout", TransitionSystem, "play_transition", [TransitionSystem.Transitions.BASIC_FADE_OUT], CONNECT_DEFERRED | CONNECT_ONESHOT)
			timer.connect("timeout", TransitionSystem, "connect", ["transition_finished", self, "_switch_to_main_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT], CONNECT_DEFERRED | CONNECT_ONESHOT)
		else:
			_skip_intro()

func _on_quarter_hit(quarter):
	if quarter in INTRO_SEQUENCE_QUARTERS:
		intro_sequence.play("Part" + str(cur_intro_part))
		
		if quarter == 16:
			_skip_intro()
		else:
			cur_intro_part += 1

func _skip_intro():
	if Conductor.is_connected("quarter_hit", self, "_on_quarter_hit"):
		Conductor.disconnect("quarter_hit", self, "_on_quarter_hit")
	intro_sequence.play("RESET")
	
	gf.show()
	logo.show()
	press_enter.show()
	flash.show()
	flash.get_node("AnimationPlayer").play("Flash")
	
	intro_skipped = true

func _switch_to_main_menu(_trans_name):
	get_parent().switch_state(MAIN_MENU)
