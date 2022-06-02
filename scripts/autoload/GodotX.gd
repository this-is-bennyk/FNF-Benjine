extends Node

const WINDOW_X = 1280
const WINDOW_Y = 720

static func get_script_filename(node: Node) -> String:
	# Get the basename of the script (the path minus the file extension)
	var script_basename: String = node.get_script().resource_path.get_basename()
	# Remove the rest of the path, which gives us the filename itself
	return script_basename.get_file()

static func is_property_path(nodepath: NodePath):
	return String(nodepath).begins_with(":")

static func xor(a, b):
	return (a && !b) || (b && !a)

static func get_haxeflixel_lerp(lerp_val):
	return lerp_val * (60.0 / Engine.get_frames_per_second()) # 30.0 / ...

static func randrange_int(min_: int, max_: int, inclusive: bool = false):
	if inclusive:
		return randi() % (min_ + 1) + (max_ - min_)
	return randi() % min_ + (max_ - min_)
