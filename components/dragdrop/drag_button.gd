class_name DragButton extends TextureButton

@export var drag_key := ""
@export var drag_owner : Node

var _inside = false

const DRAG_OWNER := "drag_owner"
const DRAG_KEY := "drag_key"
const DROP_INDEX := "drop_index"

func _ready() -> void:
	if not drag_owner:
		drag_owner = owner

func _get_drag_data(at_position: Vector2) -> Variant:
	return {DRAG_OWNER: drag_owner, DRAG_KEY: drag_key, DROP_INDEX:-1}
