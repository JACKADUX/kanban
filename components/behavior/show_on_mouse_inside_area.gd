class_name ShowOnMouseInsideArea extends Node

@export var enable := true:
	set(v):
		enable = v
		update()
@export var target_node : Control
@export var visiable_node : Control
@export_range(0,1,0.01) var from_alpha :float = 1
@export_range(0,1,0.01) var to_alpha :float = 0

@export var check_on_drag := false

var _inside := false
var _is_show_time = false

func _ready():
	if not target_node:
		target_node = get_parent()
	if not visiable_node:
		visiable_node = get_parent()
	update.call_deferred()
	
func update():
	set_process_input(enable)
	set_process(enable)
	if not visiable_node:
		return 
	if not enable:
		visiable_node.modulate.a = 1.
	else:
		visiable_node.modulate.a = to_alpha
		
func _input(event):
	if not visiable_node or not target_node:
		return 
	if event is InputEventMouseMotion:
		if event.button_mask != MOUSE_BUTTON_NONE and not check_on_drag:
			return 
			 
		if _is_show_time:
			return 
		var has_point = target_node.get_global_rect().has_point(target_node.get_global_mouse_position())
		if has_point and not _inside:
			_inside = true
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(visiable_node, "modulate:a", from_alpha, 0.2)
			
		elif not has_point and _inside:
			_inside = false
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(visiable_node, "modulate:a", to_alpha, 0.2)
		
func show_time(value:float= 3):
	_inside = true
	_is_show_time = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(visiable_node, "modulate:a", to_alpha, 0.2)
	tween.tween_callback(func(): _is_show_time = false).set_delay(value)
	
static func install_to(parent:Node, target_node:Node=null, visiable_node:Node=null, from_alpha:float=1.0, to_alpha:float=0.0) -> ShowOnMouseInsideArea:
	var agent = ShowOnMouseInsideArea.new()
	agent.target_node = target_node
	agent.visiable_node = visiable_node
	agent.from_alpha = from_alpha
	agent.to_alpha = to_alpha
	parent.add_child(agent)
	return agent
