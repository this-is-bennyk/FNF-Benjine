extends "res://scripts/game/Level.gd"

enum TrainStates {NOT_MOVING, APPROACHING, PASSING}

onready var train_passing_noise = $Train_Pass_Noise
onready var train_cooldown = $Train_Cooldown
onready var train_event_timer = $Train_Event_Timer
onready var train_anim = $ParallaxBackground/Behind_Street/Train/AnimationPlayer

var train_passing = false

#func do_level_specific_prep():
#	
	
#	characters.player.idle_frequency = 2
#	characters.opponent.idle_frequency = 2
	
#	repeating_events.add_event(
#		RepeatingGameEvent.new(
#			4,
#			Conductor.Notes.QUARTER,
#			funcref(self, "do_train_pass"),
#			[TrainStates.NOT_MOVING],
#			false,
#			8
#		)
#	)

func do_train_pass(past_state):
	match past_state:
		TrainStates.NOT_MOVING:
			if randf() <= 0.3 && !train_passing && !train_passing_noise.playing && train_cooldown.time_left == 0:
				train_cooldown.start(Conductor.get_seconds_per_beat() * (9 + randi() % 4))
				
				train_passing = true
				train_passing_noise.play()
				
				train_event_timer.start(4.7)
				train_event_timer.connect("timeout", self, "do_train_pass", [TrainStates.APPROACHING], CONNECT_DEFERRED | CONNECT_ONESHOT)
		
		TrainStates.APPROACHING:
			train_anim.play("Train_Pass")
			
			get_performer("metronome").play_anim("W3_Hair_Blow", 2.0)
			
			train_event_timer.start(1.8)
			train_event_timer.connect("timeout", self, "do_train_pass", [TrainStates.PASSING], CONNECT_DEFERRED | CONNECT_ONESHOT)
		
		TrainStates.PASSING:
			train_passing = false
			get_performer("metronome").play_anim("W3_Hair_Land", 0.5)
			get_performer("metronome").danced_right = false
			
			train_event_timer.start(0.5)
