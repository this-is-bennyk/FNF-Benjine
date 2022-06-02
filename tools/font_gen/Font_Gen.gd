extends Node

# Character list for bold font
#const CHARS = "A'B()+-&><*0123456789CDE”!FGHIJKLMNOP.Q?RS“TUVWXYZ"
# Character list for normal font
const CHARS = "%()+-0123456789;=@Aa&ß'Bb\\Cc:,Dd$↓Ee”!Ff/Gg>Hh#♡IiJjKkLl←<Mm×NnOoPp.Qq?Rr→Ss*“TtUu↑Vv|WwXxYyZz[]^_~"

func _ready():
	var bold1_font = BitmapFont.new()
	var bold2_font = BitmapFont.new()
	var cur_char = 0
	
	
	bold1_font.height = 53
	bold2_font.height = 53
	
#	bold1_font.height = 70
#	bold2_font.height = 70
	
	var alphabet_tex = load("res://assets/fonts/fnf_psych/alphabet.png")
	bold1_font.add_texture(alphabet_tex)
	bold2_font.add_texture(alphabet_tex)
	
#	print(ResourceSaver.get_recognized_extensions(new_font))
	
	var dir = Directory.new()
	dir.open("res://assets/fonts/fnf_psych/imgs")
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			pass
		else:
			var filename_no_ext = file_name.left(len(file_name) - 4)
			# Normal font
			if filename_no_ext.find("bold") == -1 && filename_no_ext.find("0002") == -1:
			# Bold font
#			if filename_no_ext.find("bold") != -1 && filename_no_ext.find("0002") != -1:
				var char_tex_b1 = load("res://assets/fonts/fnf_psych/imgs/" + file_name)
				
				var char_tex_b2_filename = file_name.left(len(file_name) - 5) + "2.res"
				var char_tex_b2 = load("res://assets/fonts/fnf_psych/imgs/" + char_tex_b2_filename)
				
				var char_to_add = CHARS.substr(cur_char, 1)
				
				var align = Vector2.ZERO
				var advance = -1
				
				if char_to_add in "abcdefghijklmnopqrstuvwxyz":
					if char_to_add.to_upper() != char_to_add:
						align.y = 53 - char_tex_b1.region.size.y
						
						# Account for letters w/ descenders
						if char_to_add in "gjpqy":
							align.y += 15
					
				else:
					match char_to_add:
						"A", "B", "C":
							align.y -= 5
						"!", "?":
							align.y -= 10
						"“", "”":
							align.y -= 25
						".", "_", ":", ";", ",":
							align.y = 53 - char_tex_b1.region.size.y
							
							if char_to_add == ";" || char_to_add == ",":
								align.y += 5
						"*", "'", "^":
							pass
						_:
							align.y = (53 - char_tex_b1.region.size.y) / 2.0
				
				# Bold font
#				if char_to_add == "“" || char_to_add == "”":
#					align.y = -25
#				elif char_to_add == "+":
#					align.y = 12
#				elif char_to_add == "-":
#					align.y = 25
#				elif char_to_add == ".":
#					align.y = 50
#				elif char_to_add == "!":
#					align.y = -10
#				elif char_to_add == "?":
#					align.y = -5
				
				if char_tex_b1.region.size.x - char_tex_b2.region.size.x != 0:
					advance = max(char_tex_b1.region.size.x, char_tex_b2.region.size.x)
				
				bold1_font.add_char(ord(char_to_add), 0, char_tex_b1.region, align, advance)
				bold2_font.add_char(ord(char_to_add), 0, char_tex_b2.region, align, advance)
				cur_char += 1
		
		yield(get_tree().create_timer(0.01), "timeout")
		file_name = dir.get_next()
	
	var space_img = Image.new()
	space_img.create(40, 70, false, Image.FORMAT_RGBA8)
	
	space_img.lock()
	for i in 40:
		for j in 70:
			space_img.set_pixel(i, j, Color.transparent)
	space_img.unlock()
	
	var space_tex = ImageTexture.new()
	space_tex.create_from_image(space_img, Texture.FLAG_FILTER)
	
	bold1_font.add_texture(space_tex)
	bold2_font.add_texture(space_tex)
	bold1_font.add_char(ord(" "), 1, Rect2(0, 0, 40, 70))
	bold2_font.add_char(ord(" "), 1, Rect2(0, 0, 40, 70))
	
#	ResourceSaver.save("res://assets/fonts/fnf_psych/FNF_Bold1.font", bold1_font, ResourceSaver.FLAG_COMPRESS)
#	ResourceSaver.save("res://assets/fonts/fnf_psych/FNF_Bold2.font", bold2_font, ResourceSaver.FLAG_COMPRESS)
	
	ResourceSaver.save("res://assets/fonts/fnf_psych/FNF_Normal1.font", bold1_font, ResourceSaver.FLAG_COMPRESS)
	ResourceSaver.save("res://assets/fonts/fnf_psych/FNF_Normal2.font", bold2_font, ResourceSaver.FLAG_COMPRESS)
	print("done")

