extends PanelContainer

signal value_changed(text:String)

@onready var container_agent: ContainerAgent = %ContainerAgent
@onready var add_button: Button = %AddButton

const TagPanel = preload("res://components/tags_panel_container/tag_panel.gd")
const TAG_PANEL_SCENE = preload("res://components/tags_panel_container/tag_panel.tscn")

func _ready() -> void:
	container_agent.clear()
	add_button.pressed.connect(func():
		var tag = _create_tag()
		_attach_line_edit(tag)
	)
	#set_value("测试, 阿达发, 1231")

func get_value() -> String:
	var tags = container_agent.get_items().filter(func(tag): return tag.label.text).map(func(tag): return tag.label.text)
	return ",".join(tags)

func set_value(tags:String):
	container_agent.clear()
	if not tags:
		return 
	for s in tags.split(","):
		_create_tag(s.strip_edges())

func _create_tag(text:String="") -> TagPanel:
	var tag = TAG_PANEL_SCENE.instantiate() as TagPanel
	container_agent.add_item(tag)
	tag.label.text = text
	tag.label.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			_attach_line_edit(tag)
	)
	tag.close_button.pressed.connect(func():
		container_agent.remove_item(tag)
		value_changed.emit(get_value())
	)
	return tag
	
func _attach_line_edit(tag:TagPanel):
	var line_edit = LabelLineEdit.install_to(tag.label)
	line_edit.activate()
	line_edit.focus_exited.connect(func():
		value_changed.emit(get_value())
		if line_edit.text == "":
			tag.queue_free()
		line_edit.queue_free()
	)
	return line_edit
