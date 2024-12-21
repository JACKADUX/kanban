class_name ContainerAgent extends Node

@export var container:Node

func get_container() -> Node:
	return container

func add_item(value:Node):
	container.add_child(value)

func get_items() -> Array:
	return container.get_children()

func move_item(value:Node, to_index:int):
	container.move_child(value, to_index)

func remove_item(value:Node):
	container.remove_child(value)

func remove_all():
	for child in container.get_children():
		remove_item(child)

func delete_item(value:Node):
	container.remove_child(value)
	value.queue_free()

func clear():
	for child in container.get_children():
		delete_item(child)

func set_container(parent:Node, p_container:Node):
	if parent:
		parent.add_child(self)
	container = p_container


static func install_to(parent:Node, p_container:Node) -> ContainerAgent:
	var agent = ContainerAgent.new()
	agent.set_container(parent, p_container)
	return agent
