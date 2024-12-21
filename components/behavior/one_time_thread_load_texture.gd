class_name LoadTextureVON extends VisibleOnScreenNotifier2D

var free_after_used:=true

static func install_to(parent:Node, fn:Callable) -> LoadTextureVON:
	var von = LoadTextureVON.new()
	parent.add_child(von)
	von.rect = Rect2(Vector2.ZERO, parent.size)
	von.screen_entered.connect(func():
		# FIXME: 虽然不会影响使用，但有几率触发 Lambda capture at index 0 was freed 的错误
		fn.call()
		if von.free_after_used:
			von.queue_free()
	)
	return von
