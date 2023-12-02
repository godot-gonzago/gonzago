@tool
extends EditorPlugin


func _init() -> void:
    name = "GonzagoPlugin"


func _enter_tree() -> void:
    pass


func _exit_tree() -> void:
    pass


func _has_main_screen() -> bool:
    return true


func _get_plugin_name() -> String:
    return "Gonzago"


func _get_plugin_icon() -> Texture2D:
    return preload("./editor/icons/gonzago.svg")
