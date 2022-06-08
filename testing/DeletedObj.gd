extends Node

onready var ref = $Node

func _ready():
	ref.queue_free()
