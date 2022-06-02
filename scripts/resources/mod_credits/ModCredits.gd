extends Resource
class_name ModCredits

export(Texture) var mod_icon
export(String) var mod_name
export(Array, Resource) var credits

func _init(
	mod_icon_: Texture = null,
	mod_name_: String = "",
	credits_: Array = []
):
	mod_icon = mod_icon_
	mod_name = mod_name_
	credits = credits_
