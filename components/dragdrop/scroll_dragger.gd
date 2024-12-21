class_name ScorllDragger extends Node

var _activate := false
@export var scroll_container :ScrollContainer
@export var scroll_speed := 20
@export var area := 30  # px
enum ScrollMode { NONE, HORIZONTAL, VERTICAL }
@export var mode := ScrollMode.NONE

func _ready() -> void:
	if not scroll_container:
		scroll_container = get_parent()
	set_process(false)
	
func _process(delta: float) -> void:
	if not mode:
		return
	var mp = scroll_container.get_local_mouse_position()
	if mode == ScrollMode.HORIZONTAL:
		if mp.x < area:
			scroll_container.scroll_horizontal -= scroll_speed
		elif mp.x > scroll_container.size.x - area:
			scroll_container.scroll_horizontal += scroll_speed
	elif mode == ScrollMode.VERTICAL:
		if mp.y < area:
			scroll_container.scroll_horizontal -= scroll_speed
		elif mp.y > scroll_container.size.y - area:
			scroll_container.scroll_horizontal += scroll_speed
		
func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_BEGIN:
			_activate = true
			set_process(true)
			
		NOTIFICATION_DRAG_END:
			_activate = false
			set_process(false)
