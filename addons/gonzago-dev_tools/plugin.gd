@tool
extends EditorPlugin


const PluginRefresher := preload("./plugin_refresher.gd")


var _plugin_refresher : PluginRefresher


func _enter_tree() -> void:
    _plugin_refresher = PluginRefresher.new()
    add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_refresher)


func _exit_tree() -> void:
    remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_refresher)
    _plugin_refresher.queue_free()
