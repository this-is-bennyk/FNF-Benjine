extends Node

export(NodePath) var anim_player_path = NodePath("AnimationPlayer")

export(String) var idle_anim_name = "Idle"
export(int) var idle_frequency = 1
export(int) var idle_offset = 0

onready var anim_player = get_node(anim_player_path)

var anim_timer = 0
var uninterrupted_anim = false

func _ready():
	on_ready()

func on_ready():
	if !Conductor.is_connected("quarter_hit", self, "on_quarter_hit"):
		Conductor.connect("quarter_hit", self, "on_quarter_hit")

func on_update(delta):
	if anim_timer > 0:
		anim_timer -= delta * Conductor.pitch_scale
		
		if anim_timer <= 0:
			_allow_interrupts()
			idle()

func on_quarter_hit(quarter):
	if idle_frequency > 0 && anim_timer <= 0 && (quarter - idle_offset) % idle_frequency == 0:
		idle()

func play_anim(anim_data, anim_length = 0, forced = true, uninterruptable = false):
	if uninterrupted_anim:
		return
	
	if anim_length:
		anim_timer = anim_length
	
	if forced:
		anim_player.stop()
	
	uninterrupted_anim = uninterruptable
	
	anim_player.playback_speed = Conductor.pitch_scale
	anim_player.play(anim_data)

func idle():
	play_anim(idle_anim_name)

func _allow_interrupts():
	uninterrupted_anim = false
