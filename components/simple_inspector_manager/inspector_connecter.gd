extends Node # class_name InspectorConnecter 

const InspectorManager = KanBan.Component.InspectorManager
	
@export var prop :String = ""
@export var force_use_signal_name := "" # 当对象类型和继承类都能被处理时可以使用此属性来直接使用想要的信号
@export var force_use_update_method := "" # 当对象类型和继承类都能被处理时可以使用此属性来直接使用想要的方法

@export var manager : InspectorManager
# signal value_changed(v) / set_value(v) / get_value()
var inspector : Node
	
func _ready():
	inspector = get_parent()
	manager.add_connecter(self)
	_connect_to_inspector()

func _connect_to_inspector(): # virtual
	if force_use_signal_name and inspector.has_signal(force_use_signal_name):
		inspector.connect(force_use_signal_name, func(v):
			manager._set_property(prop, v, self)
		)
		
	elif inspector is OptionButton:
		inspector.get_popup().transparent_bg = true
		inspector.item_selected.connect(func(v):
			manager._set_property(prop, inspector.get_item_id(v), self)
		)
	elif inspector is CheckButton or inspector is CheckBox:
		inspector.pressed.connect(func():
			manager._set_property(prop, inspector.button_pressed, self)
		)
	elif inspector is Button:
		inspector.pressed.connect(func():
			var v = true if not inspector.toggle_mode else inspector.button_pressed
			manager._set_property(prop, v, self)
		)
	elif inspector is ColorPickerButton:
		inspector.color_changed.connect(func(v):
			manager._set_property(prop, v, self)
		)
	elif inspector.has_signal("value_changed"):
		inspector.value_changed.connect(func(v):
			manager._set_property(prop, v, self)
		)
	else:
		push_error("无有效链接", inspector)

func _update_inspector(value): # virtual
	if value == null: return 
	
	elif force_use_update_method and inspector.has_method(force_use_update_method):
		Callable(inspector, force_use_update_method).call(value)
	
	elif inspector is OptionButton:
		inspector.select(inspector.get_item_index(value))
	elif inspector is CheckButton or inspector is CheckBox:
		inspector.button_pressed = value
	elif inspector is Button:
		if inspector.toggle_mode:
			inspector.button_pressed = value
	elif inspector is ColorPickerButton:
		inspector.color = value
	elif inspector.has_method("set_value"):
		inspector.set_value(value)
	else:
		push_error("无有效链接", inspector)

















