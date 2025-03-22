@tool
extends EditorScript


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
