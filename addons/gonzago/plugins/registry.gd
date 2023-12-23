@tool
class_name GonzagoEditorPluginRegistry
extends RefCounted


static var _main: GonzagoMainEditorPlugin
static var _plugins: Array[GonzagoEditorPlugin] = []


static func register(plugin: GonzagoEditorPlugin) -> void:
    if not plugin in _plugins:
        _plugins.append(plugin)


static func unregister(plugin: GonzagoEditorPlugin) -> void:
    if plugin in _plugins:
        _plugins.erase(plugin)


#static func find_configs() -> Array[StringName]:
#    var configs: Array[StringName] = []
#    for directory in DirAccess.get_directories_at("res://addons/"):
#        var config := "res://addons/%s/plugin.cfg" % directory
#        if FileAccess.file_exists(config):
#            configs.append(config)
#    return configs
