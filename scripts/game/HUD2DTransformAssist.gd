extends Position2D

#const TRANSFORMING_PROPERTIES = [
#	"position",
#	"rotation",
#	"rotation_degrees",
#	"scale",
#	"transform",
#	"global_position",
#	"global_rotation",
#	"global_rotation_degrees",
#	"global_scale",
#	"global_transform"
#]

export(NodePath) var hud_path
export(NodePath) var top_left_path = NodePath("Top_Left")

onready var hud = get_node(hud_path)
onready var top_left = get_node(top_left_path)

func update_hud_transform():
	force_update_transform()
	
	var top_left_ref = top_left if top_left else get_node(top_left_path)
	var hud_ref = hud if hud else get_node(hud_path)
	
	top_left_ref.force_update_transform()
	hud_ref.transform = top_left_ref.global_transform
