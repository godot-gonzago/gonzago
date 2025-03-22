@tool
class_name GonzagoEditorPluginRegistry
extends EditorPlugin

## Editor plugin utilities and access to central Gonzago editor plugin registry.


#static var _main: GonzagoMainEditorPlugin
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


static func get_plugin_instance_or_null() -> GonzagoEditorPluginRegistry:
    var tree := Engine.get_main_loop() as SceneTree
    var owner := tree.root
    var plugin := owner.get_node_or_null("%GonzagoEditorPluginRegistry") as GonzagoEditorPluginRegistry
    return plugin


func _init() -> void:
    name = "GonzagoEditorPluginRegistry"
    unique_name_in_owner = true
    
    
func _enter_tree() -> void:
    var root := get_tree().root
    owner = root
