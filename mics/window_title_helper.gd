extends Node

@export var product_name := ""
@export var product_version := "v0.1.0"

func _ready() -> void:
	DisplayServer.window_set_title("%s %s"%[product_name, product_version])

	
