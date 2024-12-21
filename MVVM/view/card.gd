extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var close_button: Button = %CloseButton

var view_model: NS_KANBAN.ViewModel

func _ready() -> void:
	close_button.pressed.connect(func():
		view_model.delete_card(self)
	)
	Utils.label_line_edit_on_click(title_label, func(text):
		view_model.update_card_data(self, "name", text)
	)


func set_view_model(p_view_model: NS_KANBAN.ViewModel):
	view_model = p_view_model

	view_model.card_updated.connect(func(model_id: int, key: String, value: Variant):
		if view_model.is_view_model_id(self, model_id):
			update_view(key, value)
	)

func update_view(key: String, value: Variant):
	match key:
		"name":
			if not value:
				value = "未命名"
			title_label.text = value
