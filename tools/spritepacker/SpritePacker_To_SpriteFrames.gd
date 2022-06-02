extends Node2D

# ASSUMPTIONS:
# - Sheet and image have the same path
# - Sheet is an Adobe Animate XML and image is a PNG
export(String) var load_path = "res://"
export(String) var packer_path = ""
export(String) var save_path = "res://"
export(bool) var optimize = false

onready var anim_sprite = $AnimatedSprite

func _ready():
	set_process(false)
	yield(get_tree(), "idle_frame")
	
	var anim_dict: Dictionary
	
	if packer_path == "":
		anim_dict = get_packer_anims(load_path)
	else:
		anim_dict = get_packer_anims(packer_path)
	
	var frames = anim_sprite.frames
	var texture = load(load_path + ".png")
	
	print(ResourceSaver.get_recognized_extensions(frames))
	
	for anim_name in anim_dict.keys():
		print("loaded name: " + anim_name)
		
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, false)
		frames.set_animation_speed(anim_name, 24)
		
		var anim_rects = anim_dict[anim_name]
		
		for anim_rect in anim_rects:
			var new_region = Rect2(anim_rect[0], anim_rect[1],
								   anim_rect[2], anim_rect[3])
			
			var num_frames = frames.get_frame_count(anim_name)
			var prev_frame = frames.get_frame(anim_name, num_frames - 1) if num_frames > 0 else null
			
			if optimize && prev_frame && new_region == prev_frame.region:
				print("optimizing " + str(num_frames))
				frames.add_frame(anim_name, prev_frame)
			else:
				var new_frame = AtlasTexture.new()
				new_frame.atlas = texture
				new_frame.region = new_region
				
				frames.add_frame(anim_name, new_frame)
		
		yield(get_tree().create_timer(0.01), "timeout")
	
	print("done")
	
	frames.remove_animation("default")
	ResourceSaver.save(save_path + ".res", frames, ResourceSaver.FLAG_COMPRESS)
	
	print("saved, restart the project to unfuck up the sheet")

func get_packer_anims(path: String):
	var file = File.new()
	var anim_dict = {}
	
	file.open(path + ".txt", File.READ)
	var anim_pseudo_dict = file.get_as_text().split("\n", false)
	file.close()
	
	for key_val in anim_pseudo_dict:
		var key_val_split = key_val.split(" = ", false)
		
		var anim_name_and_idx = key_val_split[0].split("_", false)
		var anim_name = anim_name_and_idx[0]
		
		var val_string_list = key_val_split[1].split(" ", false)
		var val_list = [int(val_string_list[0]), int(val_string_list[1]), int(val_string_list[2]), int(val_string_list[3])]
		
		if !anim_dict.has(anim_name):
			anim_dict[anim_name] = []
		anim_dict[anim_name].append(val_list)
	
	return anim_dict
