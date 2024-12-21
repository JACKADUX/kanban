extends PanelContainer

@onready var container_agent: ContainerAgent = %ContainerAgent
@onready var drop_area := %DropArea as DropArea
@onready var name_label: Label = %NameLabel
@onready var add_list_button: Button = %AddListButton

@onready var empty_dash_space: Panel = %EmptyDashSpace

var view_model: NS_KANBAN.ViewModel

func _ready() -> void:
	add_list_button.pressed.connect(func():
		view_model.create_list(self, {"name": "Test", "position": container_agent.get_items().size()})
	)
	Utils.label_line_edit_on_click(name_label, func(text):
		view_model.update_board_data(self, "name", text)
	)
	init_drop_area()
	

func init_drop_area():
	drop_area.drag_started.connect(func():
		var list: Control = drop_area.get_drag_data()[DragButton.DRAG_OWNER]
		var preview = NS_KANBAN.new_list()
		set_drag_preview(preview)
		preview.rotation_degrees = 5
		var scroll_container = preview.scroll_container
		scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var model_data = view_model.get_list_data(view_model.get_view_model_id(list))
		view_model.init_view(preview, model_data)
		list.modulate.a = 0
		
		set_empty_dash_space(list.get_global_rect())
		
	)

	drop_area.dragging.connect(func():
		var drag_data = drop_area.get_drag_data()
		var index = drag_data[DragButton.DROP_INDEX]
		var drag_owner = drag_data[DragButton.DRAG_OWNER]
		var drop_item = container_agent.get_items()[index]
		if drag_owner != drop_item:
			container_agent.move_item(drag_owner, index)
			
			## 
			var rect = drop_item.get_rect()
			rect = rect.grow(-16)
			var tween
			if has_meta("tween"):
				tween = get_meta("tween")
			if tween:
				tween.kill()
			if (rect.position - empty_dash_space.position).length() > rect.size.x * 2:
				set_empty_dash_space(drop_item.get_global_rect())
				return
			tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.set_parallel(true)
			tween.tween_property(empty_dash_space, "position", rect.position, 0.2)
			tween.tween_property(empty_dash_space, "size", rect.size, 0.2)
			set_meta("tween", tween)
			#
	)
	drop_area.drop_data_requested.connect(func():
		var drag_data = drop_area.get_drag_data()
		var drop_index = drag_data[DragButton.DROP_INDEX]
		var drag_owner = drag_data[DragButton.DRAG_OWNER]
		if drag_owner is not NS_KANBAN.List:
			return
		var order_ids := container_agent.get_items().map(func(l): return view_model.get_view_model_id(l))
		view_model.update_board_data(self, "sub_order", order_ids)
		
	)
	drop_area.drag_ended.connect(func():
		var list: Control = drop_area.get_drag_data()[DragButton.DRAG_OWNER]
		list.modulate.a = 1
		set_meta("tween", null)
	)

func set_empty_dash_space(rect: Rect2, grow := -16):
	rect = rect.grow(grow)
	empty_dash_space.global_position = rect.position
	empty_dash_space.size = rect.size


# view interface
func set_view_model(p_view_model: NS_KANBAN.ViewModel):
	view_model = p_view_model
	view_model.list_created.connect(func(model_id: int, list_data: Dictionary):
		if view_model.is_view_model_id(self, model_id):
			view_model.create_sub_view(self, list_data)
	)
	view_model.board_updated.connect(func(model_id: int, key: String, value: Variant):
		if view_model.is_view_model_id(self, model_id):
			update_view(key, value)
	)
	view_model.list_deleted.connect(func(model_id: int):
		view_model.delete_sub_view(self, model_id)
	)
	
func update_view(key: String, value: Variant):
	match key:
		"name":
			if not value:
				value = "未命名"
			name_label.text = value
		"sub_order":
			view_model.order_sub_views(self, value)

func get_sub_view_datas() -> Array:
	return view_model.get_all_list_data(view_model.get_view_model_id(self))

func create_sub_view() -> NS_KANBAN.List:
	return NS_KANBAN.new_list()
