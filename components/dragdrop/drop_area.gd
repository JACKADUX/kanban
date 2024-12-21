class_name DropArea extends Control

signal drag_started
signal dragging
signal drop_data_requested
signal drag_ended

@export var drop_key := ""
@export var container_agent :ContainerAgent

var _active = false
var _drag_data := {}

func _ready() -> void:
	hide()

func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_BEGIN:
			var drag_data = get_viewport().gui_get_drag_data()
			if is_valid_drop(drag_data):
				_drag_data = drag_data
				_active = true
				show()
				drag_started.emit()
				
		NOTIFICATION_DRAG_END:
			hide()
			if _active:
				_active = false
				drag_ended.emit()
				_drag_data = {}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	var container = container_agent.get_container()
	var mp = container.get_local_mouse_position()
	var index = 0
	if container is HBoxContainer:
		for item :Control in container_agent.get_items():
			if item.position.x+item.size.x*0.5 > mp.x:
				break
			index += 1
	elif container is VBoxContainer:
		for item :Control in container_agent.get_items():
			if item.position.y+item.size.y*0.5 > mp.y:
				break
			index += 1
	if data.drag_owner.get_index() < index:
		index -= 1
	data.drop_index = index
	_drag_data = data
	dragging.emit()
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	container_agent.move_item(data.drag_owner, data.drop_index)
	drop_data_requested.emit()
	

func is_valid_drop(data) -> bool:
	if not data.has(DragButton.DRAG_KEY): return false
	var drag_key = data.get(DragButton.DRAG_KEY)
	if drag_key != drop_key : return false
	return true

func get_drag_data() -> Dictionary:
	return _drag_data
	
