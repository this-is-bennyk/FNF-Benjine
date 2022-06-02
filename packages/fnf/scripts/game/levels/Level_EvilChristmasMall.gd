extends "res://scripts/game/Level.gd"

onready var scare_anim = $HUDPackage2D/HUD/ScareAnim
onready var horror_pos = $Horror_Pos

func do_pre_level_story_event():
	scare_anim.connect("animation_finished", self, "after_scare", [], CONNECT_ONESHOT | CONNECT_DEFERRED)
	scare_anim.play("Scare")

func after_scare(_anim_name):
	start_level_part_2()

func set_to_horror_pos():
	hud.camera.custom_position = horror_pos
	hud.camera.reset_position()

func unset_from_horror_pos():
	hud.camera.custom_position = null
