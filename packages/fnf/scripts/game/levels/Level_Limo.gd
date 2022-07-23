extends "res://scripts/game/Level.gd"

const CAR_PASS_NOISES = [
	preload("res://packages/fnf/resources/sounds/carPass0.ogg"),
	preload("res://packages/fnf/resources/sounds/carPass1.ogg")
]

const CAR_CHANCE = 0.1
const CAR_DURATION = 2.0

const CAR_START_X = -12600
const CAR_END_X = 6000

const CAR_Y_MIN = 140
const CAR_Y_MAX = 250

const CAR_END_POS_MULT_MIN = 0.8
const CAR_END_POS_MULT_MAX = 1.0

onready var bg_limo = $ParallaxBackground/Dancing_Demons/BG_Limo
onready var fg_limo = $FG_Limo
onready var fast_car = $ParallaxBackground/Fast_Car/FastCarLol
onready var fast_car_tween = $ParallaxBackground/Fast_Car/FastCarLol/Tween
onready var car_pass_sound = $Car_Pass_Sound

func do_level_specific_prep():
	bg_limo.play("background limo pink")
	fg_limo.play("Limo stage")

# I'm not recreating HaxeFlixel physics in Godot!!! you can't make me
func send_fast_car():
	if randf() <= CAR_CHANCE && !fast_car_tween.is_active():
		var final_x = CAR_END_X * rand_range(CAR_END_POS_MULT_MIN, CAR_END_POS_MULT_MAX)
		
		fast_car.position.x = CAR_START_X
		fast_car.position.y = randi() % CAR_Y_MIN + (CAR_Y_MAX - CAR_Y_MIN)
		
		fast_car_tween.interpolate_property(fast_car, "position:x", fast_car.position.x, final_x, CAR_DURATION / Conductor.pitch_scale)
		fast_car_tween.start()
		
		car_pass_sound.stop()
		car_pass_sound.stream = CAR_PASS_NOISES[randi() % len(CAR_PASS_NOISES)]
		car_pass_sound.play()
