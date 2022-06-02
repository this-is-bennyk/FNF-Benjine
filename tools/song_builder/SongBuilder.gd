extends Control

#const ERR_COLOR = Color("ff8888")
#const WARN_COLOR = Color("ffe788")
#const OK_COLOR = Color("adff88")

const DEFAULT_DATA = {
	package = "",
	song_folder_name = "",
	inst = {
		"name": "Inst",
		"extension": "ogg"
	},
	vocals = {
		"name": "Voices",
		"extension": "ogg"
	},
	chart_info = {
		0: "Easy",
		1: "Normal",
		2: "Hard"
	},
	default_level = ""
}

onready var package_name_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Package_Name

onready var song_folder_name_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Song_Folder_Name

onready var instrumental_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Instrumental
onready var instrumental_extension = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Instrumental/HBoxContainer/OptionButton

onready var vocals_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Vocals
onready var vocals_extension = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Vocals/HBoxContainer/OptionButton

onready var chart_info_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Chart_Info
onready var chart_info = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Chart_Info/TextEdit

onready var default_level_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Default_Level

onready var song_data_suffix_holder = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Song_Data_Suffix

onready var error_msg = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Error_Msg
onready var warning_msg = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Warning_Msg
onready var ok_msg = $Panel/VBoxContainer/Builder_Menu/VBoxContainer/Ok_Msg

onready var save_btn = $Panel/VBoxContainer/HBoxContainer/Save
onready var load_btn = $Panel/VBoxContainer/HBoxContainer/Load
onready var reset_btn = $Panel/VBoxContainer/HBoxContainer/Reset

var data = DEFAULT_DATA

func _ready():
	ResourceSaver.get_recognized_extensions(data)
#	update_builder()

func update_builder():
	var file_exists
	
	song_folder_name_holder.hide()
	instrumental_holder.hide()
	vocals_holder.hide()
	chart_info_holder.hide()
	default_level_holder.hide()
	song_data_suffix_holder.hide()
	
	error_msg.show()
	warning_msg.hide()
	ok_msg.hide()
	
	error_msg.text = "ERRORS (no saving allowed):"
	warning_msg.text = "WARNINGS (save with caution):"
	
	save_btn.disabled = true
	
	if data.package.empty():
		error_msg.text += "\nNo package provided."
		return
	
	var directory = Directory.new()
	var err = directory.open("packages/" + data.package)
	
	if err != OK:
		error_msg.text += "\nInvalid package provided."
		return
	
	song_folder_name_holder.show()
	
	if data.song_folder_name.empty():
		error_msg.text += "\nNo song folder name provided."
		return
	
	err = directory.change_dir("songs/" + data.song_folder_name)
	
	if err != OK:
		error_msg.text += "\nInvalid song folder name provided."
		return
	
	instrumental_holder.show()
	vocals_holder.show()
	chart_info_holder.show()
	default_level_holder.show()
	song_data_suffix_holder.show()
	
	warning_msg.show()
	
	if data.inst.name.empty():
		error_msg.text += "\nNo instrumental name provided."
	else:
		file_exists = directory.file_exists(data.inst.name + "." + data.inst.extension)
		
		if !file_exists:
			warning_msg.text += "\nNo instrumental file found."
	
	if data.vocals.name.empty():
		error_msg.text += "\nNo vocals name provided."
	else:
		file_exists = directory.file_exists(data.vocals.name + "." + data.vocals.extension)
		
		if !file_exists:
			warning_msg.text += "\nNo vocals file found."
	
	if data.chart_info is String && data.chart_info == "NE":
		error_msg.text += "\nNot enough chart info provided (either zero indices or missing difficulty name)."
	elif data.chart_info is String && data.chart_info == "IN":
		error_msg.text += "\nInvalid chart info provided (difficulty index is not an integer)."
	else:
		for difficulty_idx in data.chart_info.keys():
			file_exists = directory.file_exists("difficulty" + str(difficulty_idx) + ".json")
			
			if !file_exists:
				warning_msg.text += "\nChart for " + data.chart_info[difficulty_idx] + " not found."
	
	directory = Directory.new()
	err = directory.change_dir("packages/" + data.package + "/levels")
	
	if err != OK:
		error_msg.text += "\nNo folder called \"levels\" in package \"" + data.package + "\" found."
	else:
		if data.default_level.empty():
			error_msg.text += "\nNo default level provided."
		else:
			file_exists = directory.file_exists(data.default_level + ".tscn")
			
			if !file_exists:
				warning_msg.text += "\nLevel \"" + data.default_level + "\" not found."
	
	if error_msg.text == "ERRORS (no saving allowed):":
		error_msg.hide()
		save_btn.disabled = false
	
	if warning_msg.text == "WARNINGS (save with caution):":
		warning_msg.hide()
	
	if !(error_msg.visible || warning_msg.visible):
		ok_msg.show()

func _on_package_name_entered(new_text):
	data.package = new_text
	update_builder()

func _on_song_folder_name_entered(new_text):
	data.song_folder_name = new_text
	update_builder()

func _on_inst_name_entered(new_text):
	data.inst.name = new_text
	update_builder()

func _on_inst_extension_selected(index):
	data.inst.extension = instrumental_extension.get_item_text(index)
	update_builder()

func _on_vocals_name_entered(new_text):
	data.vocals.name = new_text
	update_builder()

func _on_vocals_extension_selected(index):
	data.vocals.extension = vocals_extension.get_item_text(index)
	update_builder()

func _on_chart_info_changed():
	var inputted_text = chart_info.text.split("\n", false)
	var vals_as_text = PoolStringArray()
	var new_chart_info = {}
	
	for string in inputted_text:
		vals_as_text.append_array(string.split(":", false))
	
	if len(vals_as_text) <= 0 || len(vals_as_text) % 2 != 0:
		data.chart_info = "NE"
	else:
		for i in range(0, len(vals_as_text), 2):
			var difficulty_idx = str2var(vals_as_text[i])
			var difficulty_name = vals_as_text[i + 1]
			
			if !(difficulty_idx is int):
				data.chart_info = "IN"
				break
			else:
				new_chart_info[difficulty_idx] = difficulty_name
		
		data.chart_info = new_chart_info
	
	update_builder()

func _on_default_level_entered(new_text):
	data.default_level = new_text
	update_builder()

func _on_song_data_suffix_entered(new_text):
#	data
	update_builder()
