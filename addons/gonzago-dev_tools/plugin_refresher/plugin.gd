@tool
extends GonzagoEditorPlugin


const PluginRefresher := preload("./plugin_refresher.gd")


var _plugin_refresher: PluginRefresher


func _enter_tree() -> void:
    _plugin_refresher = PluginRefresher.new()
    GonzagoEditor.get_quickbar().add_item(_plugin_refresher)


func _exit_tree() -> void:
    if _plugin_refresher:
        GonzagoEditor.get_quickbar().remove_item(_plugin_refresher)
        _plugin_refresher.queue_free()
