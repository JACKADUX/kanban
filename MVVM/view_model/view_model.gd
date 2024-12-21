#class_name KanbanViewModel

# 遵循 CURD 原则
# 	Create
# 	Update
# 	Read
# 	Delete

var db_manager: NS_KANBAN.DBManager


const EVENT_INITIALIZE = "EVENT_INITIALIZE"
const EVENT_CREATE = "EVENT_CREATE"
const EVENT_UPDATE = "EVENT_UPDATE"
const EVENT_DELETE = "EVENT_DELETE"

signal board_updated(model_id: int, key: String, value: Variant)

signal list_created(model_id: int, list_data: Dictionary)
signal list_updated(model_id: int, key: String, value: Variant)
signal list_deleted(model_id: int)

signal card_created(model_id: int, card_data: Dictionary)
signal card_updated(model_id: int, key: String, value: Variant)
signal card_deleted(model_id: int)

func _init():
	EventBus.add(EVENT_INITIALIZE)
	EventBus.add(EVENT_CREATE)
	init_db_manager()

func init_db_manager():
	db_manager = NS_KANBAN.DBManager.new("res://kanban_database")
	set_user("JACKADUX")

func set_user(username: String):
	db_manager.app_user.set_active_user(username)
	db_manager.user_id = db_manager.app_user.get_user_id(username)
	EventBus.compress_notify(EVENT_INITIALIZE)

func get_all_board_data() -> Array:
	return db_manager.board.get_all_board_data(db_manager.user_id)

func get_board_data(board_id: int) -> Dictionary:
	return db_manager.board.get_board_data(board_id)

func get_all_list_data(board_id: int) -> Array:
	return db_manager.list.get_all_list_data(board_id)

func get_list_data(list_id: int) -> Dictionary:
	return db_manager.list.get_list_data(list_id)

func get_all_card_data(list_id: int) -> Array:
	return db_manager.card.get_all_card_data(list_id)

func get_card_data(card_id: int) -> Dictionary:
	return db_manager.card.get_card_data(card_id)


func create_list(view: Control, data: Dictionary):
	var model_id = get_view_model_id(view)
	var list_data = db_manager.list.new_list(model_id, data.get("name", "未命名"), data.get("position", 10000))
	if not list_data:
		return
	list_created.emit(model_id, db_manager.list.get_list_data(list_data.id))
	EventBus.compress_notify(EVENT_CREATE)

func create_card(view: Control, data: Dictionary):
	var model_id = get_view_model_id(view)
	var card_data = db_manager.card.new_card(model_id, data.get("name", "未命名"), data.get("position", 10000))
	if not card_data:
		return
	card_created.emit(model_id, db_manager.card.get_card_data(card_data.id))
	EventBus.compress_notify(EVENT_CREATE)


func update_board_data(view: Control, key: String, value: Variant):
	var model_id = get_view_model_id(view)
	match key:
		"name":
			db_manager.board.set_name(model_id, value)
		"sub_order":
			db_manager.list.update_order(value)
		_:
			print("update_board_data: key not found")
			return
	board_updated.emit(model_id, key, value)
	EventBus.compress_notify(EVENT_UPDATE)

func update_list_data(view: Control, key: String, value: Variant):
	var model_id = get_view_model_id(view)
	match key:
		"name":
			db_manager.list.set_name(model_id, value)
		_:
			print("update_list_data: key not found")
			return
	list_updated.emit(model_id, key, value)
	EventBus.compress_notify(EVENT_UPDATE)

func update_card_data(view: Control, key: String, value: Variant):
	var model_id = get_view_model_id(view)
	match key:
		"name":
			db_manager.card.set_name(model_id, value)
		_:
			print("update_card_data: key not found")
			return
	card_updated.emit(model_id, key, value)
	EventBus.compress_notify(EVENT_UPDATE)

func delete_list(view: Control):
	var model_id = get_view_model_id(view)
	db_manager.list.delete_list(model_id)
	list_deleted.emit(model_id)
	EventBus.compress_notify(EVENT_DELETE)

func delete_card(view: Control):
	var model_id = get_view_model_id(view)
	db_manager.card.delete_card(model_id)
	card_deleted.emit(model_id)
	EventBus.compress_notify(EVENT_DELETE)


# --------------------------------------------------------------
# interface:
# 	set_view_model:
# 	update_view:
# 	get_sub_view_datas:  -> with container_agent
# 	create_sub_view:  -> with container_agent

func is_view_model_id(view: Control, model_id: int) -> bool:
	return view.get_meta("model_id") == model_id

func get_view_model_id(view: Control) -> int:
	return view.get_meta("model_id")

func init_view(view: Control, model_data: Dictionary):
	view.set_meta("model_id", model_data.id)
	view.set_view_model(self)
	update_view(view, model_data)
	if view.has_method("create_sub_view") and view.has_method("get_sub_view_datas"):
		init_sub_views(view)

func update_view(view: Control, model_data: Dictionary):
	for key in model_data:
		view.update_view(key, model_data[key])

func init_sub_views(view: Control):
	view.container_agent.clear()
	view.set_meta("sub_view_map", {})
	for sub_data in view.get_sub_view_datas(): # DBManager.list.get_all_list_data(id):
		create_sub_view(view, sub_data)

func delete_view(view: Control):
	if view.has_method("delete_view"):
		view.delete_view()
	else:
		view.queue_free()


func has_sub_view(view: Control, model_id: int) -> bool:
	return view.has_meta("sub_view_map") and view.get_meta("sub_view_map").has(model_id)

func get_sub_view(view: Control, model_id: int) -> Control:
	if not has_sub_view(view, model_id):
		return null
	return view.get_meta("sub_view_map")[model_id].get_ref()

func create_sub_view(view: Control, model_data: Dictionary) -> Control:
	var sub_view = view.create_sub_view() # NS_KANBAN.new_list()
	view.container_agent.add_item(sub_view)
	init_view(sub_view, model_data)
	view.get_meta("sub_view_map")[model_data.id] = weakref(sub_view)
	return sub_view

func order_sub_views(view: Control, model_ids: Array):
	var index = 0
	for model_id in model_ids:
		var sub_view = get_sub_view(view, model_id)
		if sub_view:
			view.container_agent.move_item(sub_view, index)
			index += 1
	for child in view.container_agent.get_items():
		if child.get_meta("model_id") not in model_ids:
			delete_sub_view(view, child.get_meta("model_id"))


func delete_sub_view(view: Control, model_id: int):
	if not has_sub_view(view, model_id):
		return
	var sub_view = get_sub_view(view, model_id)
	if sub_view: # 这里检查的原因是sub_view可能已经被删除
		view.container_agent.remove_item(sub_view)
		delete_view(sub_view)
	view.get_meta("sub_view_map").erase(model_id)
