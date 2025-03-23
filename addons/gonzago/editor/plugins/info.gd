@tool
extends RefCounted

const PluginInfo := preload("./info.gd")

var config_path: String
var plugin_id: StringName # TODO: Get by plugin id
var is_root: bool

var parent: PluginInfo
var children: Array[PluginInfo] = []

var name: String
var description: String
var author: String
var version: String
var script_path: String # TODO: Get by script (or script path). (Useful for activating subplugins?)

func _to_string() -> String:
    return (
        "config_path: %s\n" % config_path +
        "plugin_id: %s\n" % plugin_id +
        "name: %s\n" % name +
        "description: %s\n" % description +
        "author: %s\n" % author +
        "version: %s\n" % version +
        "script_path: %s\n" % script_path +
        "is_root: %s\n" % is_root +
        "parent: %s\n" % (parent.plugin_id if parent else "none") +
        "children: %d [%s]\n" % [
            children.size(),
            ", ".join(
                children.map(
                    func(child): return child.plugin_id
                )
            )
        ]
    )

func get_display_name() -> String:
    if not name.is_empty():
        return name
    return plugin_id.capitalize()

func is_enabled() -> bool:
    return EditorInterface.is_plugin_enabled(plugin_id)
    
func set_enabled(enabled: bool) -> void:
    EditorInterface.set_plugin_enabled(plugin_id, enabled)
    
func toggle() -> void:
    var enabled := EditorInterface.is_plugin_enabled(plugin_id)
    EditorInterface.set_plugin_enabled(plugin_id, not enabled)
    
func reload_deffered() -> void:
    if EditorInterface.is_plugin_enabled(plugin_id):
        EditorInterface.call_deferred("set_plugin_enabled", plugin_id, false)
    EditorInterface.call_deferred("set_plugin_enabled", plugin_id, true)
