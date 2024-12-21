extends PanelContainer

@onready var container_agent: ContainerAgent = %ContainerAgent
@onready var name_label: Label = %NameLabel

@onready var add_button: Button = %AddButton
@onready var close_button: Button = %CloseButton
@onready var scroll_container: ScrollContainer = %ScrollContainer

var view_model: NS_KANBAN.ViewModel

func _ready() -> void:
	add_button.pressed.connect(func():
		view_model.create_card(self, {"name": "test", "position": container_agent.get_items().size()})
	)
	close_button.pressed.connect(func():
		view_model.delete_list(self)
	)
	Utils.label_line_edit_on_click(name_label, func(text):
		view_model.update_list_data(self, "name", text)
	)
	

# view interface
func set_view_model(p_view_model: NS_KANBAN.ViewModel):
	view_model = p_view_model
	view_model.card_created.connect(func(model_id: int, card_data: Dictionary):
		if view_model.is_view_model_id(self, model_id):
			view_model.create_sub_view(self, card_data)
	)
	view_model.list_updated.connect(func(model_id: int, key: String, value: Variant):
		if view_model.is_view_model_id(self, model_id):
			update_view(key, value)
	)
	view_model.card_deleted.connect(func(model_id: int):
		view_model.delete_sub_view(self, model_id)
	)

func update_view(key: String, value: Variant):
	match key:
		"name":
			if not value:
				value = "未命名"
			name_label.text = value

func get_sub_view_datas() -> Array:
	return view_model.get_all_card_data(view_model.get_view_model_id(self))

func create_sub_view() -> NS_KANBAN.Card:
	return NS_KANBAN.new_card()
