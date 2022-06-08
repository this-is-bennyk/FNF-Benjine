extends Resource
class_name ModDescription

# Required info for mods
export(String) var mod_name = "My FNF Mod"
export(String) var mod_author = "Me"
export(String) var mod_version = "1.0.0"
export(String) var mod_package_name = ""
export(bool) var advanced_mod = false
# Required info for advanced mods only
export(Texture) var banner = null
export(String, FILE) var main_path = "res://scenes/Main.tscn"
export(String, MULTILINE) var description = ""

func _init(mod_name_ = "My FNF Mod",
		   mod_author_ = "Me",
		   mod_version_ = "1.0.0",
		   advanced_mod_ = false,
		   banner_ = null,
		   mod_package_name_ = "",
		   main_path_ = "",
		   description_ = ""):
	mod_name = mod_name_
	mod_author = mod_author_
	mod_version = mod_version_
	advanced_mod = advanced_mod_
	banner = banner_
	mod_package_name = mod_package_name_
	main_path = main_path_
	description = description_
