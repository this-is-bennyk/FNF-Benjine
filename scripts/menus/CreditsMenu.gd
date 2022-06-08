extends Node

const BENJINE_CREDITS = preload("res://assets/data/benjine_credits.tres")
const SEPARATOR = "-----------------------------------------------"
const MAIN_MENU = preload("res://scenes/shared/menus/default_menus/MainMenu.tscn")

onready var credits = $Credits
onready var cancel_sound = $Cancel_Sound

func _ready():
	_create_credits()
	TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_IN)

func _input(event):
	if event.is_action_released("ui_cancel"):
		cancel_sound.play()
		
		TransitionSystem.play_transition(TransitionSystem.Transitions.BASIC_FADE_OUT)
		TransitionSystem.connect("transition_finished", self, "_switch_to_main_menu", [], CONNECT_DEFERRED | CONNECT_ONESHOT)

func _create_credits():
	credits.parse_bbcode("[center]")
	
	_parse_credits(BENJINE_CREDITS)
	
	for package in UserData.get_package_names():
		if package == "fnf" || !UserData.is_basic_mod(package):
			continue
		_parse_credits(load(UserData.get_credits_path(package)))
	
	credits.append_bbcode(SEPARATOR)

func _parse_credits(mod_credits: ModCredits):
	credits.append_bbcode(SEPARATOR)
	_add_header(mod_credits.mod_icon, mod_credits.mod_name)
	credits.append_bbcode(SEPARATOR)
	
	for credit_entry in mod_credits.credits:
		if credit_entry is CreditEntry:
			_add_credit(credit_entry)

func _add_credit(credit_entry: CreditEntry):
	for icon in credit_entry.icons:
		_add_icon(icon)
	credits.append_bbcode(" ")
	_add_big_text(credit_entry.name)
	credits.append_bbcode("\n")
	
	var added_content = false
	
	credits.append_bbcode(credit_entry.roles_or_contributions)
	if credit_entry.roles_or_contributions != "":
		credits.append_bbcode("\n\n")
		added_content = true
	
	_add_links_from_credit(credit_entry)
	if len(credit_entry.links) > 0:
		credits.append_bbcode("\n\n")
		added_content = true
	
	if !added_content:
		credits.append_bbcode("\n")

func _add_links_from_credit(credit_entry: CreditEntry):
	var num_links = len(credit_entry.links)
	var num_link_names = len(credit_entry.link_names)
	var num_link_colors = len(credit_entry.link_colors)
	
	if num_links > 0 && num_links == num_link_names:
		for i in num_links:
			var color = credit_entry.link_colors[i] if i < num_link_colors else Color.white
			_add_link(credit_entry.links[i], credit_entry.link_names[i], color)
			
			if i < num_links - 1:
				credits.append_bbcode(" / ")

func _add_header(icon: Texture, title: String):
	_add_icon(icon)
	credits.append_bbcode(" ")
	_add_big_text(title)

func _add_icon(texture: Texture):
	credits.append_bbcode("[img=73]" + texture.resource_path + "[/img]")

func _add_big_text(string: String):
	credits.append_bbcode("[b]" + string + "[/b]")

func _add_link(link: String, link_name: String, link_color: Color = Color.white):
	var result = ""
	
	result += "[color=#" + link_color.to_html(false) + "]"
	result += "[url=" + link + "]"
	result += link_name
	result += "[/url]"
	result += "[/color]"
	
	credits.append_bbcode(result)

func _on_link_clicked(meta):
	OS.shell_open(str(meta))

func _switch_to_main_menu(_trans_name):
	get_parent().switch_state(MAIN_MENU)
