extends Control

@onready var board := %Board as NS_KANBAN.Board

var kanban_view_model: NS_KANBAN.ViewModel

func _ready() -> void:
	kanban_view_model = NS_KANBAN.ViewModel.new()
	EventBus.listen(NS_KANBAN.ViewModel.EVENT_INITIALIZE, func():
		kanban_view_model.init_view(board, kanban_view_model.get_all_board_data()[0])
	)
