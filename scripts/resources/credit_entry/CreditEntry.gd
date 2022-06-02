extends Resource
class_name CreditEntry

const DEFAULT_ICON = preload("res://assets/graphics/menus/credits/unknown_credit.tres")

export(Array, Texture) var icons = [DEFAULT_ICON]
export(String) var name
export(String, MULTILINE) var roles_or_contributions
export(Array, String) var links
export(Array, String) var link_names
export(Array, Color) var link_colors

func _init(
	icons_: Array = [DEFAULT_ICON],
	name_: String = "",
	roles_or_contributions_: String = "",
	links_: Array = [],
	link_names_: Array = [],
	link_colors_: Array = []
):
	icons = icons_
	name = name_
	roles_or_contributions = roles_or_contributions_
	links = links_
	link_names = link_names_
	link_colors = link_colors_
