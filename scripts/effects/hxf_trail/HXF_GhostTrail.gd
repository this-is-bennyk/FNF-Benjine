extends Node2D

# ASSUMPTION: the lead sprite inherits from CanvasItem
# ASSUMPTION: the DEFAULT initial and updating properties
#             assume the lead sprite to be a AnimatedSprite

export(NodePath) var lead_sprite_path

export(Array, String) var initial_properties = [
	"centered"
]
export(Array, String) var updating_properties = [
	"frames",
	"animation",
	"frame",
	"offset",
	"flip_h",
	"flip_v",
	"global_transform"
]

export(int)   var num_trailsprites = 10
export(float) var update_delay = 0.03
export(float) var start_alpha = 0.4
export(float) var diff_alpha = 0.05

onready var lead_sprite = get_node_or_null(lead_sprite_path)

var trailsprites = []

func _ready():
	if lead_sprite:
		generate_trailsprites()
		_start_delay()

func generate_trailsprites():
	# Get every property to initialize
	var all_properties = []
	
	all_properties.append_array(initial_properties)
	all_properties.append_array(updating_properties)
	
	# Start in reverse order to make alpha calculations easier
	var ts_indices = range(num_trailsprites)
	ts_indices.invert()
	
	# Initialize all trailing sprites
	for ts_idx in ts_indices:
		var trailsprite = ClassDB.instance(lead_sprite.get_class())
		
		for property in all_properties:
			trailsprite.set(property, lead_sprite.get(property))
		trailsprite.modulate.a = start_alpha - (diff_alpha * ts_idx)
		
		add_child(trailsprite)
	
	trailsprites = get_children()

func _update_trail():
	var ts_idx = len(trailsprites) - 1
	
	while ts_idx >= 0:
		var previous_sprite = lead_sprite if ts_idx == 0 else trailsprites[ts_idx - 1]
		
		for property in updating_properties:
			trailsprites[ts_idx].set(property, previous_sprite.get(property))
		
		ts_idx -= 1
	
	_start_delay()

func _start_delay():
	var timer = get_tree().create_timer(update_delay, false)
	timer.connect("timeout", self, "_update_trail", [], CONNECT_DEFERRED | CONNECT_ONESHOT)
