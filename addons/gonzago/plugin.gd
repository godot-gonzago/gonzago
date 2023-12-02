@tool
extends EditorPlugin


#static var _dependant_plugins: Array[GonzagoEditorPlugin] = []


#static func register_dependant_plugin(plugin: GonzagoEditorPlugin) -> void:
#    if not plugin in _dependant_plugins:
#        _dependant_plugins.push_back(plugin)


func _init() -> void:
    name = "GonzagoCorePlugin"


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
