extends Node # InspectorManager 

const InspectorConnecter = KanBan.Component.InspectorConnecter

var inspector_connecters :Array[InspectorConnecter] = []

func add_connecter(connector:InspectorConnecter):
	inspector_connecters.append(connector)

func update_inspector(prop:String, value):
	for ic:InspectorConnecter in inspector_connecters:
		if ic.prop == prop:
			ic._update_inspector(value)

func update_inspectors():
	for ic:InspectorConnecter in inspector_connecters:
		ic._update_inspector(_get_property(ic.prop))

func check_inspectors_prop():
	for ic:InspectorConnecter in inspector_connecters:
		if _get_property(ic.prop) == null:
			print("属性未指定返回值：'%s'"%ic.prop)

func collect_data() -> Dictionary:
	var data := {}
	for ic:InspectorConnecter in inspector_connecters:
		var value = _get_property(ic.prop)
		if value == null:
			continue
		data[ic.prop] = value
	return data
	
func _set_property(prop, value, connector):  # virtual
	# _data[prop] = value
	pass
		
func _get_property(prop):  # virtual
	#  _data.get(prop)
	return 
	
