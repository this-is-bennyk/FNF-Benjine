extends CanvasLayer

onready var cur_menu = $Menus/Category_Select
onready var menus = [
	$Menus/Category_Select,
	$Menus/Gameplay,
	$Menus/Audio,
	$Menus/Controls,
	$"Menus/Mod-Specific"
]

onready var submenu_desc = $Submenu_Desc
onready var anim_player = $AnimationPlayer

func _enter_tree():
	VolumeChanger.disabled = true

func _exit_tree():
	VolumeChanger.disabled = false

func _on_anim_finished(anim_name):
	if anim_name == "Move_Out":
		anim_player.disconnect("animation_finished", self, "_on_anim_finished")
		queue_free()

func on_input(event: InputEvent):
	if !(anim_player.is_playing() || anim_player.assigned_animation == "Move_Out"):
		cur_menu.on_input(event)

func change_menu(idx):
	cur_menu.hide()
	
	cur_menu = menus[idx]
	cur_menu.show()
	submenu_desc.text = cur_menu.submenu_desc
	
	if idx != 0:
		cur_menu.reset()

func exit():
	anim_player.play("Move_Out")
	get_parent().handle_options_exit()
