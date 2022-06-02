extends Node2D

# ASSUMPTIONS:
# - Sheet and image have the same path
# - Sheet is an Adobe Animate XML and image is a PNG
export(String) var load_path = "res://"
export(String) var save_path = "res://"
export(bool) var optimize = false

func _ready():
	set_process(false)
	yield(get_tree(), "idle_frame")
	
	var xml_parser = XMLParser.new()
	var open_err = xml_parser.open(load_path + ".xml")
	
	var texture = load(load_path + ".png")
	var prev_img = null
#	var tex_atlas = AtlasTexture.new()
#
#	print(ResourceSaver.get_recognized_extensions(tex_atlas))
#
	var err = xml_parser.read()
	while err == OK:
		if xml_parser.get_node_type() == XMLParser.NODE_ELEMENT || xml_parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			print("--- " + xml_parser.get_node_name() + " ---")

			if xml_parser.get_node_name() != "TextureAtlas":
				var loaded_name: String = xml_parser.get_named_attribute_value("name")
				print("loaded name: " + loaded_name)

				var new_region = Rect2(int(xml_parser.get_named_attribute_value("x")), int(xml_parser.get_named_attribute_value("y")),
									   int(xml_parser.get_named_attribute_value("width")), int(xml_parser.get_named_attribute_value("height")))
				var new_margin = Rect2()
				if xml_parser.has_attribute("frameX"):
					new_margin = Rect2(-int(xml_parser.get_named_attribute_value("frameX")), -int(xml_parser.get_named_attribute_value("frameY")),
										int(xml_parser.get_named_attribute_value("frameWidth")) - new_region.size.x, int(xml_parser.get_named_attribute_value("frameHeight")) - new_region.size.y)
#
				if optimize && prev_img && new_region == prev_img.region && new_margin == prev_img.margin:
					print("optimizing " + loaded_name)
				else:
					var new_img = AtlasTexture.new()
					new_img.atlas = texture
					new_img.region = new_region
					new_img.margin = new_margin
					new_img.flags = Texture.FLAG_MIPMAPS
					new_img.filter_clip = true
					
					ResourceSaver.save(save_path + "_" + loaded_name + ".res", new_img, ResourceSaver.FLAG_COMPRESS)
					
					prev_img = new_img
					
		yield(get_tree().create_timer(0.01), "timeout")
		err = xml_parser.read()
#
	print("done")
#
#	frames.remove_animation("default")
#	ResourceSaver.save(save_path + ".res", frames, ResourceSaver.FLAG_COMPRESS)
#
	print("saved, restart the project to unfuck up the imgs prolly")
