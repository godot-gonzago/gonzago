@tool
extends EditorFileDialog

const NodeUtil := Gonzago.NodeUtil
const MessageBox := preload("uid://kxasjqh1gf3b")
const _Self := preload("uid://du3avwykyyuv1")

signal request_theme_open(path: String)
signal request_theme_save(path: String)


func _init() -> void:
    filters = _get_filters()
    
    about_to_popup.connect(_load_state)
    canceled.connect(_save_state)
    confirmed.connect(_save_state)
    
    file_selected.connect(_file_selected)
    files_selected.connect(_files_selected)
    dir_selected.connect(_dir_selected)


func _get_recognized_extentions() -> PackedStringArray:
    return ResourceLoader.get_recognized_extensions_for_type(&"Theme")


func _get_filters() -> PackedStringArray:
    var filters: PackedStringArray = []
    for extension in _get_recognized_extentions():
        filters.append("*.%s;%s" % [extension, extension.to_upper()])
    return filters


func _load_state() -> void:
    pass # TODO: Load selection from last time


func _save_state() -> void:
    pass # TODO: Save selection for next time


func _is_file_path_of_type_theme(path: String) -> bool:
    if Engine.is_editor_hint():
        var fs := EditorInterface.get_resource_filesystem()
        var type := fs.get_file_type(path)
        return ClassDB.is_parent_class(type, &"Theme")
        
    var theme := ResourceLoader.load(path, &"Theme")
    if not theme: return false
    if theme.is_class(&"Theme"): return true
    
    var script := theme.get_script() as Script
    if not script: return false
    var type := script.get_instance_base_type()
    return ClassDB.is_parent_class(type, &"Theme")


func _file_selected(path: String) -> void:
    if file_mode == EditorFileDialog.FILE_MODE_SAVE_FILE:
        _file_selected_for_saving(path)
    else:
        _file_selected_for_opening(path)


func _file_selected_for_saving(path: String) -> void:
    request_theme_save.emit(path)


func _file_selected_for_opening(path: String) -> void:
    var is_theme_type := _is_file_path_of_type_theme(path)
    if not is_theme_type:
        MessageBox.show_message(
            tr("Selected file is not of type Theme!"),
            tr("Type missmatch!")
        )
        return
    request_theme_open.emit(path)


func _files_selected(paths: PackedStringArray) -> void:
    var paths_to_open: PackedStringArray = []
    for path in paths:
        if _is_file_path_of_type_theme(path):
            paths_to_open.append(path)
    
    var failed_paths_count := paths.size() - paths_to_open.size()
    if failed_paths_count > 0:
        MessageBox.show_message(
            tr("%d files are not of type Theme!" % failed_paths_count),
            tr("Type missmatch!")
        )
    
    for path in paths_to_open:
        request_theme_open.emit(path)


func _dir_selected(dir: String) -> void:
    push_error("Not implemented yet!")


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_TRANSLATION_CHANGED:
            _update_title()


func _update_title() -> void:
    match file_mode:
        EditorFileDialog.FILE_MODE_OPEN_FILE:
            title = tr("Open Theme Resource")
        EditorFileDialog.FILE_MODE_OPEN_FILES, EditorFileDialog.FILE_MODE_OPEN_ANY:
            title = tr("Open Theme Resources")
        EditorFileDialog.FILE_MODE_OPEN_DIR:
            title = tr("Open Theme Resources in Directory")
        EditorFileDialog.FILE_MODE_SAVE_FILE:
            title = tr("Create Theme Resource")


static func create_dialog(mode := EditorFileDialog.FileMode.FILE_MODE_OPEN_FILE) -> _Self:
    var dialog := _Self.new()
    dialog.file_mode = mode
    return dialog


static func create_open_dialog() -> _Self:
    return create_dialog(EditorFileDialog.FileMode.FILE_MODE_OPEN_FILE)


static func create_save_dialog() -> _Self:
    return create_dialog(EditorFileDialog.FileMode.FILE_MODE_SAVE_FILE)
