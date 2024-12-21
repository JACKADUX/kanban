class_name TextureManager

var temp_path := "user://temp_texture/"

const IMAGE_EXTENSION = ["png", "jpg", "jpeg", "webp", "svg"]
const IMAGE_FILETER_EXTENSION = ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg"]

var hash_texture_datas := {}
var path_texture_datas := {}

#---------------------------------------------------------------------------------------------------
func clear():
	hash_texture_datas = {}
	path_texture_datas = {}

func get_count() -> int:
	return hash_texture_datas.size()

#---------------------------------------------------------------------------------------------------
static func image_to_64(value:Image) -> String:
	return Marshalls.raw_to_base64(value.save_png_to_buffer())

#---------------------------------------------------------------------------------------------------
static func image_from_64(value:String) -> Image:
	var image = Image.new()
	image.load_png_from_buffer(Marshalls.base64_to_raw(value))
	return image

#---------------------------------------------------------------------------------------------------
static func resize_image(image:Image, max_size:=1024) -> Image:
	# NOTE: 该方法只会缩小 不会放大
	# 让所有图片的最长边等于max_size，并等比缩放
	var image_size = image.get_size() 
	var aspect :float= image_size.aspect()
	var new_x:float
	var new_y:float
	var small_image :Image = image.duplicate(true)
	if image_size[image_size.max_axis_index()] > max_size:
		if aspect > 1:  # x>y
			new_x = max_size
			new_y = new_x/aspect
		else:
			new_y = max_size
			new_x = new_y*aspect
		small_image.resize(int(new_x), int(new_y))
	return small_image
	
#---------------------------------------------------------------------------------------------------
static func resize_images(images:Array[Image], max_size:=1024) -> Array[Image]:
	# 让所有图片的最长边等于max_size，并等比缩放
	var small_images :Array[Image]= [] 
	for image:Image in images:
		small_images.append(resize_image(image, max_size))
	return small_images

#---------------------------------------------------------------------------------------------------
func get_texture(path:String):
	if path_texture_datas.has(path):
		var texture = instance_from_id(path_texture_datas[path])
		if texture is Texture2D:  
			return texture
	
#---------------------------------------------------------------------------------------------------
func load_texture_from_path(path:String, max_size:=-1) -> Texture2D:
	if not path:
		return 
	var texture = get_texture(path)
	if texture:
		return texture
	if not FileAccess.file_exists(path):
		return 
	texture = create_texture_from_file(path, max_size)
	var ins_id = texture.get_instance_id()
	path_texture_datas[path] = ins_id
	var hash_id = get_image_data_hash(texture.get_image())
	hash_texture_datas[hash_id] = path
	return texture

#---------------------------------------------------------------------------------------------------
func get_texture_path(texture:Texture2D, save:=false) -> String:
	if not texture:
		return ""
	var image = texture.get_image()
	var path = hash_texture_datas.get(get_image_data_hash(image))
	if not path and save:
		DirAccess.make_dir_absolute(temp_path)
		var hash_id = get_image_data_hash(image)
		path = temp_path.path_join(hash_id+".png")
		texture.get_image().save_png(path)
	return path


#---------------------------------------------------------------------------------------------------
static func open_image_dialog(muilty_files:=false) -> Array:
	var _dialog_title := "选择图片"
	var files := []
	if not muilty_files:
		files = file_dialog(_dialog_title, [",".join(IMAGE_FILETER_EXTENSION)], DisplayServer.FILE_DIALOG_MODE_OPEN_FILE)
	else:
		files = file_dialog(_dialog_title, [",".join(IMAGE_FILETER_EXTENSION)], DisplayServer.FILE_DIALOG_MODE_OPEN_FILES)
	return files
	

static func get_all_image_path_from(dir_path:String):
	var image_paths = []
	for file :String in DirAccess.get_files_at(dir_path):
		if file.get_extension() not in TextureManager.IMAGE_EXTENSION:
			continue
		image_paths.append(dir_path.path_join(file))
	return image_paths

#---------------------------------------------------------------------------------------------------
func export_image(image:Image, file_path:String):
	match file_path.get_extension():
		"png": image.save_png(file_path)
		"jpg": image.save_jpg(file_path)

#---------------------------------------------------------------------------------------------------
static func get_image_data_hash(value:Image):
	return str(hash(value.get_data()))

#---------------------------------------------------------------------------------------------------
static func is_same_texture(a:Texture2D, b:Texture2D) -> bool:
	return get_image_data_hash(a.get_image()) == get_image_data_hash(b.get_image())

static func is_same_image(a:Image, b:Image) -> bool:
	return get_image_data_hash(a) == get_image_data_hash(b)

#---------------------------------------------------------------------------------------------------
static func create_texture_from_file(path:String, max_size:=-1) -> Texture2D:
	var image = Image.load_from_file(path)
	if max_size != -1:
		image = resize_image(image, max_size)
	return ImageTexture.create_from_image(image)

#---------------------------------------------------------------------------------------------------
func create_texture_from_buffer(byte_array:PackedByteArray, extension:String) -> Texture2D:
	var image = Image.new()
	match extension:
		"png":
			image.load_png_from_buffer(byte_array)
		"jpg","jpeg":
			image.load_jpg_from_buffer(byte_array)
		"webp":
			image.load_webp_from_buffer(byte_array)
		"svg":
			image.load_svg_from_buffer(byte_array)
	var texture = ImageTexture.create_from_image(image)
	return texture

static func file_dialog(title:String="Files", filter=[], mode=DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, current_directory: String="", filename: String="") -> Array:
	var files = []
	var _on_folder_selected = func(status:bool, selected_paths:PackedStringArray, selected_filter_index:int):
		if not status:
			return
		files.append_array(selected_paths)
	DisplayServer.file_dialog_show(title, current_directory, filename,false,
								mode,
								filter,
								_on_folder_selected)
	return files
