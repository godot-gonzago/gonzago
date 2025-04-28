@tool
extends GonzagoEditorPlugin

const ToDos := preload("uid://by27t0v8r56kw")
const ToDosScene := preload("uid://ejo1jf6smwlu")

var _todo: ToDos


func _enter_tree() -> void:
    _todo = ToDosScene.instantiate() as ToDos
    add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, _todo)


func _exit_tree() -> void:
    if _todo:
        remove_control_from_docks(_todo)
        _todo.queue_free()
