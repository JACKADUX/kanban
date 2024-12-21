class_name NodePool extends Node

var pool := []
@export var max_count = 5

func create(create_fn :Callable) -> Node:
	for node:Node in pool:
		if not node.is_inside_tree():
			return node
	var node :Node = create_fn.call()
	pool.append(node)
	return node

func clear_edge():
	while max_count < pool.size():
		pool.pop_back().queue_free()
