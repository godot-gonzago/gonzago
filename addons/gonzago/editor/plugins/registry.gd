@tool
@static_unload
class_name GonzagoEditorPluginRegistry
extends RefCounted

## Editor plugin utilities and access to central Gonzago editor plugin registry.

const PLUGINS_ROOT := "res://addons/"
const CONFIG_FILE_NAME := "plugin.cfg"

const PluginInfo := preload("./info.gd")

static var _plugins_cache_dirty := true

static var _plugins_map: Dictionary[StringName, PluginInfo] = {}
static var _plugins_root_cache: Array[PluginInfo] = []


static func _build_plugins_cache() -> void:
    _plugins_map.clear()
    _plugins_root_cache.clear()
    
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
        
        var plugin_id := dir.get_path().trim_prefix(PLUGINS_ROOT).simplify_path()
        var is_root_plugin := not plugin_id.contains("/")
        
        var info := PluginInfo.new()
        info.config_path = config_path
        info.plugin_id = plugin_id
        info.is_root = is_root_plugin
        
        info.name = str(config.get_value("plugin", "name", ""))
        info.description = str(config.get_value("plugin", "description", ""))
        info.author = str(config.get_value("plugin", "author", ""))
        info.version = str(config.get_value("plugin", "version", ""))
        info.script_path = str(config.get_value("plugin", "script", ""))
        
        _plugins_map[plugin_id] = info
        if is_root_plugin:
            _plugins_root_cache.append(info)
            continue
        
        var parent_id := plugin_id
        while parent_id.contains("/"):
            parent_id = parent_id.rsplit("/", false, 1)[0]
            if _plugins_map.has(parent_id):
                var parent := _plugins_map[parent_id] as PluginInfo
                info.parent = parent
                parent.children.push_back(info)
                break
    
    #for info in _plugins_root_cache:
    #    print(info)
        
    _plugins_cache_dirty = false
    EditorInterface.get_resource_filesystem().filesystem_changed.connect(
        func() -> void:
            _plugins_cache_dirty = true,
        Object.CONNECT_ONE_SHOT
    )
    
static func get_plugins() -> Array[PluginInfo]:
    if _plugins_cache_dirty:
        _build_plugins_cache()
    return _plugins_root_cache


#static var _main: GonzagoMainEditorPlugin
#static var _plugins: Array[GonzagoEditorPlugin] = []


#static func register(plugin: GonzagoEditorPlugin) -> void:
#    if not plugin in _plugins:
#        _plugins.append(plugin)


#static func unregister(plugin: GonzagoEditorPlugin) -> void:
#    if plugin in _plugins:
#        _plugins.erase(plugin)


#static func find_configs() -> Array[StringName]:
#    var configs: Array[StringName] = []
#    for directory in DirAccess.get_directories_at("res://addons/"):
#        var config := "res://addons/%s/plugin.cfg" % directory
#        if FileAccess.file_exists(config):
#            configs.append(config)
#    return configs
