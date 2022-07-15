extends Label

const BINDING_TEXT = "..."

onready var input1_key = $HBoxContainer/Input1_Key
onready var input1_btn = $HBoxContainer/Input1_Btn
onready var input1_btn_frames = $HBoxContainer/Input1_Btn/BtnFrames

onready var input2_key = $HBoxContainer/Input2_Key
onready var input2_btn = $HBoxContainer/Input2_Btn
onready var input2_btn_frames = $HBoxContainer/Input2_Btn/BtnFrames

var action_package: String
var action_name: String

var input1: InputEvent
var input2: InputEvent

var on_first_input = true
var binding = false

func _ready():
	text = action_name.capitalize()
	
	set_input_displays(true)
	set_input_displays(false)
	
	set_current_input_display(true)

func on_input(event: InputEvent):
	if event.is_action_released("bind_key") && !binding:
		binding = true
		set_to_binding_state()
	
	elif binding && !event.is_pressed():
		if !event.is_action_released("ui_cancel") && (event is InputEventKey || event is InputEventJoypadButton):
			if on_first_input:
				input1 = event
			else:
				input2 = event
			UserData.set_setting(action_name, [input1, input2], "input", action_package)
			
			if !InputMap.has_action(action_name):
				InputMap.add_action(action_name)
			
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, input1)
			InputMap.action_add_event(action_name, input2)
		
		binding = false
		set_input_displays(on_first_input)

func set_input_displays(first_input):
	var input = input1 if first_input else input2
	var input_key = input1_key if first_input else input2_key
	var input_btn = input1_btn if first_input else input2_btn
	var input_btn_frames = input1_btn_frames if first_input else input2_btn_frames
	
	if input is InputEventKey:
		input_btn.hide()
		
		input_key.visible = on_first_input if first_input else !on_first_input
		input_key.text = input.as_text()
	else: # Assumed to be InputEventJoypadButton
		input_key.hide()
		
		input_btn.visible = on_first_input if first_input else !on_first_input
		input_btn_frames.frame = input.button_index if input.button_index < KeybindEntry.UNKNOWN_JOYPAD_BTN else KeybindEntry.UNKNOWN_JOYPAD_BTN

func set_current_input_display(on_first_input_: bool):
	on_first_input = on_first_input_
	
	set_input_displays(true)
	set_input_displays(false)

func set_to_binding_state():
	var input_key = input1_key if on_first_input else input2_key
	var input_btn = input1_btn if on_first_input else input2_btn
	
	input_btn.hide()
	input_key.show()
	input_key.text = BINDING_TEXT
