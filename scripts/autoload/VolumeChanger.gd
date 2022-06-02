extends CanvasLayer

const MASTER_IDX = 0

onready var bars = [
	$BG/Bar1,
	$BG/Bar2,
	$BG/Bar3,
	$BG/Bar4,
	$BG/Bar5,
	$BG/Bar6,
	$BG/Bar7,
	$BG/Bar8,
	$BG/Bar9,
	$BG/Bar10,
]
onready var anim_player = $AnimationPlayer

var disabled = false
var muted = false

func _input(event):
	if disabled:
		return
	
	if GodotX.xor(event.is_action_released("master_volume_up"), event.is_action_released("master_volume_down")):
		var increment = 1 if event.is_action_released("master_volume_up") else -1
		var new_vol = int(clamp(UserData.get_setting("Master", 10, "audio") + increment, 0, 10))
		
		UserData.set_setting("Master", new_vol, "audio")
		
		muted = false
		AudioServer.set_bus_mute(MASTER_IDX, muted)
		AudioServer.set_bus_volume_db(MASTER_IDX, linear2db(float(new_vol) / 10.0))
		
		display_new_volume(new_vol)
		
	elif event.is_action_released("master_volume_mute"):
		muted = !muted
		AudioServer.set_bus_mute(MASTER_IDX, muted)
		
		if muted:
			display_new_volume(0)
		else:
			display_new_volume(UserData.get_setting("Master", 10, "audio"))

func display_new_volume(new_vol):
	for bar_idx in len(bars):
		if bar_idx + 1 <= new_vol:
			bars[bar_idx].color.a = 1.0
		else:
			bars[bar_idx].color.a = 0.5
	
	anim_player.stop()
	anim_player.play("Change")
