extends Node

enum DeathState {START, LOOP, END}

export(NodePath) var hud_path
export(NodePath) var camera_path
export(NodePath) var player_character_path
export(NodePath) var fade_screen_path
export(NodePath) var loss_sfx_path
export(NodePath) var end_sfx_path

export(AudioStream) var death_music = preload("res://assets/music/gameOver.ogg")
export(float) var death_music_bpm = 100

onready var hud = get_node(hud_path)
onready var camera = get_node(camera_path)
onready var player_character = get_node(player_character_path)
onready var fade_screen = get_node(fade_screen_path)
onready var loss_sfx = get_node(loss_sfx_path)
onready var end_sfx = get_node(end_sfx_path)

var cam_pos_from_level = Vector2(770, 450)
var zoom_from_level = Vector2(1 / 0.7, 1 / 0.7)
var player_pos_from_level = Vector2(770, 450)
var player_scale_from_level = Vector2.ONE

var returning_to_level = false

func _ready():
	call_deferred("advance_death_state", DeathState.START)

func advance_death_state(state):
	match state:
		DeathState.START:
			player_character.position = player_pos_from_level
			player_character.scale = player_scale_from_level
			
			camera.follow_point = player_character.camera_follow_point
			camera.reset_position(cam_pos_from_level)
			hud.follow_viewport_scale = zoom_from_level.x
			camera.zoom = zoom_from_level
			
			player_character.play_anim("Death_Start")
			player_character.anim_player.connect("animation_finished", self, "_advance_after_start", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
			
			loss_sfx.play()
			
		DeathState.LOOP:
			Conductor.play_music(death_music, death_music_bpm)
		
		DeathState.END:
			loss_sfx.stop()
			end_sfx.play()
			player_character.play_anim("Death_Confirm")
			Conductor.stop_song()
			
			get_tree().create_timer(0.7).connect("timeout", fade_screen.get_node("AnimationPlayer"), "play", ["Fade"], CONNECT_ONESHOT)
			get_tree().create_timer(2.7).connect("timeout", TransitionSystem, "start_transition", ["Instant_Fade_Out"], CONNECT_ONESHOT)
			get_tree().create_timer(2.7).connect("timeout", get_parent(), "restart", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _advance_after_start(anim_name):
	advance_death_state(DeathState.LOOP)

func _process(delta):
	on_update()

func on_update():
	if Input.is_action_just_pressed("ui_accept"):
		if player_character.anim_player.is_connected("animation_finished", self, "_advance_after_start"):
			player_character.anim_player.disconnect("animation_finished", self, "_advance_after_start")
		
		camera.reset_position()
		advance_death_state(DeathState.END)
		set_process(false)
		return
	else:
		camera.on_update()
