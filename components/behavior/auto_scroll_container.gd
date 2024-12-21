extends Node

@export var scroll_container : ScrollContainer
func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion and event.pressure == 0:
		var node = get_viewport().gui_get_hovered_control()
		if scroll_container.is_ancestor_of(node):
			scroll_container.vertical_scroll_mode = scroll_container.SCROLL_MODE_AUTO
		else:
			scroll_container.vertical_scroll_mode = scroll_container.SCROLL_MODE_SHOW_NEVER
		
	
