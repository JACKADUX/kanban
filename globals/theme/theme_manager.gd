class_name ThemeManager

var builder : ThemeTypeBuilder

var theme_path := "res://resource/formauto_theme.tres"


	# https://www.behance.net/gallery/161215951/Eos-Design-System-UI-kit-Library
	
const int_4 :int = 4
const int_8 :int = 8
const int_12 :int = 12
const int_16 :int = 16
const int_24 :int = 24
const int_32 :int = 32
const int_40 :int = 40

const color_white := Color.WHITE

# Brand  # 变化时饱和度降低/明度增加 -> 向白色
const color_blue_iris :=  Color("#5755FF")
const color_safety_orange := Color("#FF8F6B")
const color_amber := Color("#FEB63D")
const color_pale_iris := Color("#D9D7FF")

# Neutrals  # 变化时饱和度降低/明度增加 -> 向白色
const color_text_primary := Color("#0E0D35")
const color_text_subtext := Color("#626C7A")

# Background
const color_gray_pale := Color("#F4F6F9")
const color_gray_neutral := Color("#F8F8F9")
const color_gray_hover := Color("#F4F3FF")

# System
const color_notice := Color("#51CC56")
const color_warning := Color("#5B93FF")
const color_error := Color("#FF5555")

# Icon
static var icon_type := "line_art"

# Component
static var stroke = 2

static var text_size_offset = -4   # 不同字体尺寸会不一样可以根据字体调整
# Titles  # bug？ 24px的字体实际大小是25 多一个像素所以-1
static var text_h1 :int :  # onboarding Bold
	get: return 38 +text_size_offset  -1  
static var text_h2 :int :  # primary semi-bold
	get: return 34 +text_size_offset  -1 
static var text_h3 :int :  # secondary medium
	get: return 30 +text_size_offset  -1 

static var text_subtitle :int :  
	get: return 26 +text_size_offset  -1 
static var text_body :int :  
	get: return 24 +text_size_offset  -1 
static var text_details :int :  
	get: return 20 +text_size_offset  -1 
static var text_small :int :  
	get: return 18 +text_size_offset  -1 

#
static var contrast :float = 0.2

const BASE_FONT = null

func offset_color(color:Color, brightness:float=0, saturation:float=0) -> Color:
	color.v *= 1 + brightness
	color.s *= 1 + saturation
	return color


func initialize():
	if not OS.has_feature("editor"):
		return
	builder = ThemeTypeBuilder.new(load(theme_path))
	builder.theme.clear()
	
	builder.default_font_size = text_body
	builder.theme.default_font = BASE_FONT
	
	create_label()
	create_panel_container()
	create_button()
	create_margin()
	create_option_button()
	create_line_edit()
	create_checkbox()
	create_popup_panel()
	create_popup_menu()
	create_accept_dialog()
	
	create_sidebar()
	create_canvas_inspector()
	
	builder.save(theme_path)

func create_accept_dialog():
	var base_frame = (MonadStyleBox.create_with_flat().bg_color(color_white)
			.corner(int_8)
			.content_margin(int_32)
			).get_stylebox()
			
	(builder.add_type("AcceptDialog")
		.set_stylebox("panel", base_frame)
		.set_constant("buttons_min_height", int_32)
		.set_constant("buttons_min_width", 120)
		.set_constant("buttons_seperation", int_32)
	)

func create_popup_menu():
	const CHECKED = preload("res://assets/icons/checked.png")
	#const ALERT_TRIANGLE = preload("res://resource/icons/alert_triangle.png")
	var base_frame = (MonadStyleBox.create_with_flat().bg_color(color_white)
			.corner(int_8).border(stroke).border(6, SIDE_BOTTOM)
			.border_color(Color(color_text_subtext,0.5))
			.content_margin(int_8)
			.content_margin(int_8, SIDE_TOP)
			.content_margin(int_12, SIDE_BOTTOM)
			).get_stylebox()
			
	var base_frame_hover = (MonadStyleBox.create_with_flat()
			.bg_color(color_blue_iris)
			.expand_margin(int_8-2, SIDE_LEFT)
			.expand_margin(int_8-2, SIDE_RIGHT)
			).get_stylebox()
			
	(builder.add_type("PopupMenu")
		.set_stylebox("panel", base_frame)
		.set_stylebox("hover", base_frame_hover)
		.set_icon("checked", CHECKED)
		#.set_icon("submenu", ALERT_TRIANGLE)
		.set_font_size("font_size", int_16)
		.set_constant("v_seperation", int_24)
		.set_color("font_hover_color", color_white)
		.set_color("font_color", color_text_primary)
		.set_color("font_disabled_color", Color(color_text_subtext, 0.8))
	)
	
func create_popup_panel():
	var base_frame = (MonadStyleBox.create_with_flat().bg_color(color_white)
			.corner(int_8).border(stroke).border(stroke*2, SIDE_BOTTOM)
			.border_color(Color(color_text_subtext,0.5))
			.content_margin(int_16)
			.content_margin(int_8, SIDE_TOP)
			.content_margin(int_12, SIDE_BOTTOM)
			).get_stylebox()
	(builder.add_type("PopupPanel")
		.set_stylebox("panel", base_frame)
	)

func create_checkbox():
	const CHECKBOX = preload("res://assets/icons/checkbox.png")
	const CHECKBOX_UNCHECKED = preload("res://assets/icons/checkbox_unchecked.png")
	
	var monad_data = MonadStyleBox.with_data(MonadStyleBox.create_with_flat("base").empty()
		.new_branch_retrave("base", "normal")
		.new_branch_retrave("base", "pressed")
		.new_branch_retrave("base", "hover")
		.new_branch_retrave("base", "disabled")
		.new_branch_retrave("base", "focus")
		.new_branch_retrave("base", "hover_pressed")
	)
	
	(builder.add_type("CheckBox")
		.button_set_stylebox_data(monad_data)
		.button_set_font_color_all(color_text_primary)
		.button_set_icon_color_all(color_blue_iris)
		.set_icon("checked", CHECKBOX)
		.set_icon("unchecked", CHECKBOX_UNCHECKED)
	)

func create_line_edit():
	var base_frame = (MonadStyleBox.create_with_flat().corner(int_16)
			.draw_center(false)
			.content_margin_seperate(int_16, -1, int_16, -1)
			).get_stylebox()

	(builder.add_type("LineEdit")
		.button_set_font_color_all(color_gray_neutral)
		.set_stylebox("focus", MonadStyleBox.EMPTY)
		.set_stylebox("normal", base_frame)
		.set_constant("h_separation", int_24)
		.set_constant("arrow_margin", int_24)
		.set_font_size("font_size", text_details)
		.set_color("caret_color", color_text_subtext)
		.set_color("clear_button_color", color_text_subtext)
		.set_color("font_placeholder_color", color_text_subtext)
		.set_color("font_color", color_text_primary)
	)

func create_option_button():
	var base_frame = (MonadStyleBox.create_with_flat().corner(int_16)
			.content_margin_seperate(int_24, int_4, int_24, int_4)
			).get_stylebox()
			
	var monad_data = MonadStyleBox.with_data(MonadStyleBox.new(base_frame, "base")
		.new_branch_retrave("base", "normal").bg_color(color_blue_iris)
		.new_branch_retrave("base", "pressed").bg_color(offset_color(color_blue_iris, -contrast))
		.new_branch_retrave("base", "hover").bg_color(offset_color(color_blue_iris, contrast))
		.new_branch_retrave("base", "disabled").bg_color(offset_color(color_gray_neutral, -contrast))
		.new_branch_retrave("base", "focus").empty()
	)
	(builder.add_type("OptionButton")
		.button_set_font_color_all(color_gray_neutral)
		.button_set_stylebox_data(monad_data)
		.set_constant("h_separation", int_24)
		.set_constant("arrow_margin", int_24)
		.set_font_size("font_size", text_details)
	)

func create_label():
	builder.add_type("Label").set_color("font_color", color_text_primary)
	

func create_panel_container():
	var main_panel = MonadStyleBox.create_with_flat().bg_color(color_gray_neutral).get_stylebox()
	builder.add_type("PanelContainer").panel_set_stylebox(main_panel)
	
	# Region
	var region_panel = (MonadStyleBox.create_with_flat()
			.draw_center(false).corner(int_8)
			.border_color(Color(color_text_subtext, 0.1))
			.border(stroke)
			).get_stylebox()
	builder.add_type("panel_region", "PanelContainer").panel_set_stylebox(region_panel)

func create_button():
	var monad_data
	var base_frame = MonadStyleBox.create_with_flat().corner(int_16) \
			.content_margin_seperate(int_32, int_16, int_32, int_16) \
			.get_stylebox()
	
	# Contained
	monad_data = MonadStyleBox.with_data(MonadStyleBox.new(base_frame, "base")
		.new_branch_retrave("base", "normal").bg_color(color_blue_iris)
		.new_branch_retrave("base", "pressed").bg_color(offset_color(color_blue_iris, -contrast))
		.new_branch_retrave("base", "hover").bg_color(offset_color(color_blue_iris, contrast))
		.new_branch_retrave("base", "disabled").bg_color(offset_color(color_gray_neutral, -contrast))
		.new_branch_retrave("base", "focus").empty()
	)
	
	(builder.add_type("btn_contained", "Button")
		.button_set_stylebox_data(monad_data)
		.button_set_color_all(color_gray_neutral)
		.set_color("font_disabled_color", offset_color(color_gray_neutral, -contrast*2))
	)
	
	# Outlined
	monad_data = MonadStyleBox.with_data(MonadStyleBox.new(base_frame, "base")
			.bg_color(color_blue_iris).draw_center(false).border(2)
		.new_branch_retrave("base", "normal").border_color(color_blue_iris)
		.new_branch_retrave("base", "pressed").border_color(offset_color(color_blue_iris, -contrast))
			.draw_center(true).bg_alpha(0.2)
		.new_branch_retrave("base", "hover").border_color(offset_color(color_blue_iris, contrast))
			.draw_center(true).bg_alpha(0.1)
		.new_branch_retrave("base", "disabled").border_color(offset_color(color_gray_neutral, -contrast))
		.new_branch_retrave("base", "focus").empty()
	)
	
	(builder.add_type("btn_outlined", "Button")
		.button_set_stylebox_data(monad_data)
		.button_set_color_all(color_blue_iris)
		.set_color("font_disabled_color", offset_color(color_gray_neutral, -contrast*2))
	)
	
	# Texted
	monad_data = MonadStyleBox.with_data(MonadStyleBox.new(base_frame, "base")
			.bg_color(offset_color(color_blue_iris, -contrast)).draw_center(false).border(0)
		.new_branch_retrave("base", "normal").draw_center(false)
		.new_branch_retrave("base", "pressed").draw_center(true).bg_alpha(0.2)
		.new_branch_retrave("base", "hover").draw_center(true).bg_color(color_gray_hover)
		.new_branch_retrave("base", "disabled").empty()
		.new_branch_retrave("base", "focus").empty()
	)
	
	(builder.add_type("btn_texted", "Button")
		.button_set_stylebox_data(monad_data)
		.button_set_color_all(color_blue_iris)
		.set_color("font_disabled_color", offset_color(color_gray_neutral, -contrast*2))
	)
	
	
	base_frame = (MonadStyleBox.create_with_flat().corner(int_16)
			.content_margin(int_12)
			).get_stylebox()
			
	# Icon Outlined
	monad_data = MonadStyleBox.with_data(MonadStyleBox.new(base_frame, "base")
			.bg_color(offset_color(color_blue_iris, -contrast)).draw_center(false).border(0)
		.new_branch_retrave("base", "normal").draw_center(false)
		.new_branch_retrave("base", "pressed").draw_center(true).bg_alpha(0.2)
		.new_branch_retrave("base", "hover").draw_center(true).bg_color(color_gray_hover)
		.new_branch_retrave("base", "disabled").empty()
		.new_branch_retrave("base", "focus").empty()
	)
	
	
	(builder.add_type("btn_icon_only", "Button")
		.button_set_stylebox_data(monad_data)
		.button_set_color_all(color_blue_iris)
	)

func create_margin():
	(builder.add_type("margin_frame", "MarginContainer")
			.margin_set_side(int_24, SIDE_LEFT)
			.margin_set_side(int_32, SIDE_TOP)
			.margin_set_side(int_24, SIDE_RIGHT)
			.margin_set_side(int_32, SIDE_BOTTOM)
	)


# -- 

func create_sidebar():
	# Panel
	var sidebar_panel = (MonadStyleBox.create_with_flat()
			.bg_color(color_white)
			#.content_margin_seperate(int_24, int_32, int_24, int_32)
			).get_stylebox()
	builder.add_type("panel_sidebar", "PanelContainer").panel_set_stylebox(sidebar_panel)
	
	# Button
	var sidebar_base_frame =( MonadStyleBox.create_with_flat().corner(int_16).border(0)
			.content_margin_seperate(-1, int_12, -1, int_12)
			.expand_margin_seperate(int_12, -1, int_12, -1)
			
			).get_stylebox()
	var monad_data = MonadStyleBox.with_data(MonadStyleBox.new(sidebar_base_frame, "base")
		.new_branch_retrave("base", "normal").draw_center(false)
		.new_branch_retrave("base", "pressed").bg_color(color_gray_hover)
		.new_branch_retrave("base", "hover").draw_center(false)
		.new_branch_retrave("base", "disabled").empty()
		.new_branch_retrave("base", "focus").empty()
	)
	
	(builder.add_type("btn_sidebar", "Button")
		.button_set_stylebox_data(monad_data)
		.button_set_color_all(color_text_subtext)
		.set_constant("h_separation", int_8)
		.button_set_color("pressed_color", color_blue_iris)
		.button_set_color("hover_color", color_blue_iris)
	)

func create_canvas_inspector():
	var main_panel = (MonadStyleBox.create_with_flat().bg_color(color_white)
			.border(1).border_color(offset_color(color_white, -contrast))
			.corner(int_8).shadow(Color(Color.BLACK, 0.15), 2, Vector2(0, 2))
			.content_margin(int_8)
			).get_stylebox()
	(builder.add_type("panel_inspector_canvas", "PanelContainer")
		.panel_set_stylebox(main_panel)
	)
	
	
	(builder.add_type("btn_inspector_canvas", "Button")
		.button_set_color_all(color_text_subtext)
		.set_color("icon_hover_color", color_blue_iris)
		.set_color("icon_disabled_color", offset_color(color_text_subtext, contrast))
	)
	




















