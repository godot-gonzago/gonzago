@tool
extends GonzagoEditorPlugin
## Gonzago.DevTools.PluginRefresher editor plugin.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html


const PluginRefresher := preload("./plugin_refresher.gd")


var _plugin_refresher: PluginRefresher


func _enter_tree() -> void:
    _plugin_refresher = PluginRefresher.new()
    GonzagoEditorInterface.get_quickbar().add_item(_plugin_refresher)


func _exit_tree() -> void:
    if _plugin_refresher:
        GonzagoEditorInterface.get_quickbar().remove_item(_plugin_refresher)
        _plugin_refresher.queue_free()
