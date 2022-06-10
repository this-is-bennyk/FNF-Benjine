extends Label

const BINDING_TEXT = "???"

onready var key_string = $Key_String

var action_package: String
var action_name: String
var action_input: InputEvent

var binding = false

func _ready():
	text = action_name.capitalize()
	key_string.text = action_input.as_text()

func on_input(event: InputEvent):
	if event.is_action_released("bind_key") && !binding:
		binding = true
		key_string.text = BINDING_TEXT
	
	elif binding && !event.is_pressed():
		if !event.is_action_released("ui_cancel") && (event is InputEventKey || event is InputEventJoypadButton):
			action_input = event
			UserData.set_setting(action_name, action_input, "input", action_package)
			
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, action_input)
		
		binding = false
		key_string.text = action_input.as_text()
