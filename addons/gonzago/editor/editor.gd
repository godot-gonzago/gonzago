@tool
@static_unload
class_name GonzagoEditor
extends RefCounted

## Editor utilities.

#region Plugins

class PluginInfo extends RefCounted:
    var name: String
    var description: String
    var author: String
    var version: String
    var plugin_script: String
    
    var plugin_id: String
    var is_root: bool
    
    var parent: PluginInfo
    var children: Array[PluginInfo] = []
    
    #func add_child(info: PluginInfo) -> void:
    #    children.push_back(info)
    
    func _to_string() -> String:
        return (
            "name: %s\n" % name +
            "description: %s\n" % description +
            "author: %s\n" % author +
            "version: %s\n" % version +
            "plugin_script: %s\n" % plugin_script +
            "plugin_id: %s\n" % plugin_id +
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


const PLUGINS_ROOT := "res://addons/"
const CONFIG_FILE_NAME := "plugin.cfg"

static var _plugins_cache_dirty := true
static var _plugins_cache: Array[PluginInfo] = []


static func _build_plugins_cache() -> void:
    _plugins_cache.clear()
    var plugins_id_map: Dictionary[String, PluginInfo] = {}
    
    var fs := EditorInterface.get_resource_filesystem()
    var root := fs.get_filesystem_path(PLUGINS_ROOT)
    if not root:
        return
        
    var stack: Array[EditorFileSystemDirectory] = []
    stack.push_back(root)
    
    while not stack.is_empty():
        var dir := stack.pop_back() as EditorFileSystemDirectory
        var sub_idx := dir.get_subdir_count() - 1
        while sub_idx >= 0:
            var subdir := dir.get_subdir(sub_idx)
            stack.push_back(subdir)
            sub_idx -= 1
            
        var file_idx := dir.find_file_index(CONFIG_FILE_NAME)
        if file_idx == -1:
            continue
        
        var config_path := dir.get_file_path(file_idx)
        var config := ConfigFile.new()
        if not config.load(config_path) == OK or not config.has_section("plugin"):
            continue
        
        var info := PluginInfo.new()
        info.plugin_id = dir.get_path().trim_prefix(PLUGINS_ROOT).simplify_path()
        info.name = str(config.get_value("plugin", "name", ""))
        info.description = str(config.get_value("plugin", "description", ""))
        info.author = str(config.get_value("plugin", "author", ""))
        info.version = str(config.get_value("plugin", "version", ""))
        info.plugin_script = str(config.get_value("plugin", "script", ""))
        
        info.is_root = not info.plugin_id.contains("/")
        var parent_id := info.plugin_id
        while parent_id.contains("/"):
            parent_id = parent_id.rsplit("/", false, 1)[0]
            if plugins_id_map.has(parent_id):
                var parent := plugins_id_map[parent_id] as PluginInfo
                info.parent = parent
                parent.children.push_back(info)
                break
            
        _plugins_cache.append(info)
        plugins_id_map[info.plugin_id] = info
    
    for info in _plugins_cache:
        print(info)
        
    _plugins_cache_dirty = false
    EditorInterface.get_resource_filesystem().filesystem_changed.connect(
        func() -> void:
            _plugins_cache_dirty = true,
        Object.CONNECT_ONE_SHOT
    )
    
static func get_plugins() -> Array[PluginInfo]:
    if _plugins_cache_dirty:
        _build_plugins_cache()
    return _plugins_cache

#endregion
