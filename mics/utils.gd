class_name Utils

static func label_line_edit_on_click(label:Label, fn:Callable):
	label.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.double_click:
			var line_edit = LabelLineEdit.install_to(label)
			line_edit.activate()
			line_edit.focus_exited.connect(func():
				line_edit.queue_free()
				fn.call(line_edit.text)
			)
	)
