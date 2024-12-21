extends Node

@export var color_name := "color_blue_iris"

func _ready():
	get_parent().self_modulate = GlobalSetting.theme_manager.get(color_name)
	
