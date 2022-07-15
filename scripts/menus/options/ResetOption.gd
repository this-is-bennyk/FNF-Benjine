extends Label

const CONFIRM_DIALOGUE = "You sure? (Game will exit.)"

export(bool) var reset_scores = false
export(bool) var reset_settings = false

var original_text = ""
var primed = false

func _ready():
	original_text = text

func on_input(event: InputEvent):
	if event.is_action("ui_accept"):
		if !primed:
			primed = true
			text = CONFIRM_DIALOGUE
			return
		
		var dir = Directory.new()
		
		if reset_scores:
			dir.remove(UserData.SAVE_DATA_PATH)
		if reset_settings:
			dir.remove(UserData.SETTINGS_DATA_PATH)
		
		get_tree().quit()

func unprime():
	primed = false
	text = original_text
