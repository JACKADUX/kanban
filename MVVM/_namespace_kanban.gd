class_name NS_KANBAN


# model
const DBManager = preload("res://MVVM/model/dbmanager.gd")


# view
const Board = preload("res://MVVM/view/board.gd")
const BOARD_SCENE = preload("res://MVVM/view/board.tscn")
const Card = preload("res://MVVM/view/card.gd")
const CARD_SCENE = preload("res://MVVM/view/card.tscn")
const List = preload("res://MVVM/view/list.gd")
const LIST_SCENE = preload("res://MVVM/view/list.tscn")

static func new_list() -> List:
	return LIST_SCENE.instantiate()

static func new_card() -> Card:
	return CARD_SCENE.instantiate()


# view_model
const ViewModel = preload("res://MVVM/view_model/view_model.gd")
