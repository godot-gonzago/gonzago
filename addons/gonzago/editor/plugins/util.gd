@tool
extends EditorScript

# THIS IS UNUSED!!! ONLY FOR REFERENCE!


#[plugin]
#
#name="Gonzago"
#description="Gonzago Framework - 2D/3D Adventure game addon for the Godot game engine"
#author="David Krummenacher & Gonzago Framework contributors"
#version="0.0.1"
#script="plugin.gd"


class PluginInfo extends RefCounted:
    var name: String
    var description: String
    var author: String
    var version: String
    var plugin_script: String
    
    var plugin_name: String
    
    func is_enabled() -> bool:
        return EditorInterface.is_plugin_enabled(plugin_name)
        
    func set_enabled(enabled: bool) -> void:
        EditorInterface.set_plugin_enabled(plugin_name, enabled)
        
    func reload_deffered() -> void:
        if EditorInterface.is_plugin_enabled(plugin_name):
            EditorInterface.call_deferred("set_plugin_enabled", plugin_name, false)
            EditorInterface.call_deferred("set_plugin_enabled", plugin_name, true)
        
    static func from_config_file(config_path: String) -> PluginInfo:
        if not FileAccess.file_exists(config_path):
            return null
            
        var config := ConfigFile.new()
        if not config.load(config_path) == OK or not config.has_section("plugin"):
            return null
        
        var info := PluginInfo.new()
        
        if config.has_section_key("plugin", "name"):
            info.name = str(config.get_value("plugin", "name", ""))
        if info.name.is_empty():
            var plugin_name := config_path.get_base_dir().get_file()
            info.name = plugin_name
            
        info.description = str(config.get_value("plugin", "description", ""))
        info.author = str(config.get_value("plugin", "author", ""))
        info.version = str(config.get_value("plugin", "version", ""))
        
        info.plugin_script = str(config.get_value("plugin", "script", ""))
        if info.plugin_script.is_empty():
            var plugin_name := config_path.get_base_dir().get_file()
            info.plugin_script = plugin_name + ".gd"
            
        return info


# https://forum.godotengine.org/t/deep-er-dive-on-godot-custom-iterators-and-the-mysterious-arg/92474
class EditorFileSystemIterator extends RefCounted:
    var _root_folder: String
    var _stack: Array[EditorFileSystemDirectory] = []
    
    func _init(root: String) -> void:
        _root_folder = root
        
    func _iter_init(iter: Array) -> bool:
        var fs := EditorInterface.get_resource_filesystem()
        var root := fs.get_filesystem_path(_root_folder)
        if not root:
            iter[0] = ""
            return false
            
        _stack.clear()
        _stack.push_back(root)
        
        return _iter_next(iter)
        
    func _iter_next(iter: Array) -> bool:
        while not _stack.is_empty():
            var dir := _stack.pop_back() as EditorFileSystemDirectory
            var sub_idx := dir.get_subdir_count() - 1
            while sub_idx >= 0:
                var subdir := dir.get_subdir(sub_idx)
                _stack.push_back(subdir)
                sub_idx -= 1
                
            var file_idx := dir.find_file_index("plugin.cfg")
            if file_idx > -1:
                iter[0] = dir.get_file_path(file_idx)
                return true
        iter[0] = ""
        return false
        
    func _iter_get(current: Variant) -> String:
        return str(current)


func _run() -> void:
    # Find all addons
    
    var t1 := Time.get_ticks_usec()
    print("Editor File System")
    var editor_file_system_results := _find_via_editor_file_system()
    print("\n".join(editor_file_system_results))
    print(Time.get_ticks_usec() - t1)
    
    var t2 := Time.get_ticks_usec()
    print("===========================")
    print("File System")
    var file_system_results := _find_via_file_system()
    print("\n".join(file_system_results))
    print(Time.get_ticks_usec() - t2)
    
    var t3 := Time.get_ticks_usec()
    print("===========================")
    print("Editor File System Iterator")
    var editor_fs_iterator := EditorFileSystemIterator.new("res://addons/")
    for entry in editor_fs_iterator:
        print(entry)
    print(Time.get_ticks_usec() - t3)


func _find_via_editor_file_system() -> PackedStringArray:
    var result: PackedStringArray = []
    
    var fs := get_editor_interface().get_resource_filesystem()
    var root := fs.get_filesystem_path("res://addons/")
    if not root:
        return result
        
    var stack: Array[EditorFileSystemDirectory] = []
    stack.push_back(root)
    
    while not stack.is_empty():
        var dir := stack.pop_back() as EditorFileSystemDirectory
        var sub_idx := dir.get_subdir_count() - 1
        while sub_idx >= 0:
            var subdir := dir.get_subdir(sub_idx)
            stack.push_back(subdir)
            sub_idx -= 1
            
        var file_idx := dir.find_file_index("plugin.cfg")
        if file_idx > -1:
            result.append(dir.get_file_path(file_idx))
        
    return result


func _find_via_file_system() -> PackedStringArray:
    var result: PackedStringArray = []
    
    var stack: Array[String] = []
    stack.push_back("res://addons/")
    
    while not stack.is_empty():
        var current_path := stack.pop_back() as String
        var dir := DirAccess.open(current_path)
        if not dir:
            continue
            
        var subdirs := dir.get_directories()
        var sub_idx := len(subdirs) - 1
        while sub_idx >= 0:
            var subdir := subdirs[sub_idx]
            var subdir_path := current_path.path_join(subdir)
            stack.push_back(subdir_path)
            sub_idx -= 1
            
        var file_path := current_path.path_join("plugin.cfg")
        if FileAccess.file_exists(file_path):
            result.append(file_path)
    
    return result
