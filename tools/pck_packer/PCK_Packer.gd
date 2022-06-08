extends Node

signal finished_packing

export(String) var package_name = "my_fnf_mod"
export(Array, String, DIR) var folders_excluded = []
#export(Array, String) var files_excluded = []
export(Array, String) var extensions_excluded = ["json"]

var package_path = "res://packages"
var desc_folder = ""

func _ready():
	package_path = package_path.plus_file(package_name)
	desc_folder = package_path.plus_file("desc")
	call_deferred("pack_package")

func pack_package():
	if !_directory_exists(package_path):
		print("Not a valid package directory")
		return
	
	var mod_desc: ModDescription = UserData.get_mod_desc(package_name)
	
	var pck_packer = PCKPacker.new()
	pck_packer.pck_start(mod_desc.mod_package_name + ".pck")
	print("Starting pack")
	
	pack_all_in_folder(pck_packer, package_path)
	yield(self, "finished_packing")
	
	print("Attempting flush")
	pck_packer.flush(true)
	print("Finished pack")
	
	# HACK: I overwrite the package path to pack specifically the description
	package_path = desc_folder
	
	pck_packer.pck_start(mod_desc.mod_package_name + ".desc.pck")
	print("Starting description pack")
	
	pack_all_in_folder(pck_packer, package_path)
	yield(self, "finished_packing")
	
	print("Attempting flush")
	pck_packer.flush(true)
	print("Finished description pack")

func pack_all_in_folder(pck_packer: PCKPacker, path: String):
	if !_directory_exists(path):
		return
	
	var directory := Directory.new()
	var open_err = directory.open(path)
	
	directory.list_dir_begin()
	var file_name = directory.get_next()
	
	while file_name != "":
		if directory.current_is_dir():
			# Pack the contents of the folder (unless it's a self / parent reference or it's being excluded)
			if !(file_name.begins_with(".") || (directory.get_current_dir() in folders_excluded) || directory.get_current_dir() == desc_folder):
				var result = pack_all_in_folder(pck_packer, path.plus_file(file_name))
				while result is GDScriptFunctionState:
					result = yield(result, "completed")
		
		else:
			# Pack the file (unless it's extension is excluded)
			if !(file_name.get_extension() in extensions_excluded):
				var file_path = directory.get_current_dir().plus_file(file_name)
				var file_err = pck_packer.add_file(file_path, file_path)
				print("Attempted to pack file " + file_name + " at " + file_path + ": " + str(file_err))
				
				# If this is a .import file, pack the actual import file it's pointing to
				if file_name.get_extension() == "import":
					var import_file = ConfigFile.new()
					import_file.load(file_path)
					
					for key in import_file.get_section_keys("remap"):
						if !key.begins_with("path"):
							continue
						
						var import_data_path = import_file.get_value("remap", key)
						file_err = pck_packer.add_file(import_data_path, import_data_path)
						print("Attempted to pack .import file of " + file_name + " at " + import_data_path + ": " + str(file_err))
		
		yield(get_tree().create_timer(0.1), "timeout")
		file_name = directory.get_next()
	
	if path == package_path:
		emit_signal("finished_packing")

func _directory_exists(path: String):
	return Directory.new().open(path) == OK
