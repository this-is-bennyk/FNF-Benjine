extends ARVRController

const TRIGGER_PRESS_THRESHOLD = 0.6

signal activated
signal deactivated

#signal trigger_pressed
#signal trigger_released

var checked_activation = false
#var activated = false

#var _trigger_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !checked_activation:
		check_activation()
#	if !activated:
#		return
	
#	check_trigger()

func check_activation():
	if get_is_active():
#		visible = true
		print("Activated " + name)
		emit_signal("activated")
	elif visible:
#		visible = false
		print("Deactivated " + name)
		emit_signal("deactivated")
	
#	activated = visible
	checked_activation = true

#func check_trigger():
#	if _trigger_is_pressed():
#		_trigger_pressed = true
#		emit_signal("trigger_pressed")
#
#	elif _trigger_is_released():
#		_trigger_pressed = false
#		emit_signal("trigger_released")
#
#func _trigger_is_pressed():
#	return get_joystick_axis(JOY_VR_ANALOG_TRIGGER) > TRIGGER_PRESS_THRESHOLD && !_trigger_pressed
#func _trigger_is_released():
#	return get_joystick_axis(JOY_VR_ANALOG_TRIGGER) < TRIGGER_PRESS_THRESHOLD && _trigger_pressed
