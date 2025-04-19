@tool
extends EditorFileDialog

const NodeUtil := Gonzago.NodeUtil
const MessageBox := preload("uid://kxasjqh1gf3b")
const _Self := preload("uid://du3avwykyyuv1")

signal request_theme_open(path: String)
signal request_themes_open(paths: PackedStringArray)
signal request_theme_save(path: String)


func _init() -> void:
    filters = _get_filters()

    about_to_popup.connect(_load_state)
    canceled.connect(_save_state)
    confirmed.connect(_save_state)

    file_selected.connect(_file_selected)
    files_selected.connect(_files_selected)
    dir_selected.connect(_dir_selected)


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_TRANSLATION_CHANGED:
            _update_title()


func _load_state() -> void:
    pass # TODO: Load selection from last time


func _save_state() -> void:
    pass # TODO: Save selection for next time


func _get_filters() -> PackedStringArray:
    var filters: PackedStringArray = []
    for extension in ResourceLoader.get_recognized_extensions_for_type(&"Theme"):
        filters.append("*.%s;%s" % [extension, extension.to_upper()])
    return filters


func _is_file_path_of_type_theme(path: String) -> bool:
    var fs := EditorInterface.get_resource_filesystem()
    var type := fs.get_file_type(path)
    return ClassDB.is_parent_class(type, &"Theme")


func _file_selected(path: String) -> void:
    match file_mode:
        EditorFileDialog.FILE_MODE_SAVE_FILE:
            request_theme_save.emit(path)
        EditorFileDialog.FILE_MODE_OPEN_FILE, EditorFileDialog.FILE_MODE_OPEN_ANY:
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

    if paths_to_open.is_empty():
        MessageBox.show_message(
            tr("No selected files are of type Theme!"),
            tr("Type missmatch!")
        )
        return

    var failed_paths_count := paths.size() - paths_to_open.size()
    if failed_paths_count > 0:
        MessageBox.show_message(
            tr("%d selected files are not of type Theme!" % failed_paths_count),
            tr("Type missmatch!")
        )

    request_themes_open.emit(paths_to_open)


func _dir_selected(path: String) -> void:
    var fs := EditorInterface.get_resource_filesystem()
    var dir_stack: Array[String] = [path]
    var paths_to_open: PackedStringArray = []

    while not dir_stack.is_empty():
        var dir_path := dir_stack.pop_back()
        var dir := fs.get_filesystem_path(dir_path)

        for sub_dir_idx in range(dir.get_subdir_count(), -1, -1):
            var sub_dir_path := dir.get_subdir(sub_dir_idx)
            dir_stack.append(sub_dir_path)

        for file_idx in dir.get_file_count():
            var file_path := dir.get_file_path(file_idx)
            if _is_file_path_of_type_theme(file_path):
                paths_to_open.append(file_path)

    if paths_to_open.is_empty():
        MessageBox.show_message(
            tr("No Themes found in directory %s or any of its sub directories!" % path),
            tr("No Themes!")
        )
        return

    request_themes_open.emit(paths_to_open)


func _update_title() -> void:
    match file_mode:
        EditorFileDialog.FILE_MODE_OPEN_FILE:
            title = tr("Open Theme Resource")
        EditorFileDialog.FILE_MODE_OPEN_FILES, EditorFileDialog.FILE_MODE_OPEN_ANY:
            title = tr("Open Theme Resources")
        EditorFileDialog.FILE_MODE_OPEN_DIR:
            title = tr("Open Theme Resources Directory")
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
