extends Resource
class_name ResourceList

export(Array, Resource) var list := []

func _init(list_: Array = []):
	list = list_
