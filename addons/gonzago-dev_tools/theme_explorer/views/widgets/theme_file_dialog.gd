@tool
extends EditorFileDialog

const NodeUtil := Gonzago.NodeUtil
const _Self := preload("uid://du3avwykyyuv1")

signal request_theme_open(theme: Theme)
signal request_theme_save(path: String)


func _init() -> void:
    for extension in _get_recognized_extentions():
        filters.append("*.%s;%s" % [extension, extension.to_upper()])
    
    about_to_popup.connect(_load_state)
    canceled.connect(_save_state)
    confirmed.connect(_save_state)
    
    file_selected.connect(_file_selected)
    files_selected.connect(_files_selected)
    dir_selected.connect(_dir_selected)


func _get_recognized_extentions() -> PackedStringArray:
    return ResourceLoader.get_recognized_extensions_for_type("Theme")


func _load_state() -> void:
    pass # TODO: Load selection from last time


func _save_state() -> void:
    pass # TODO: Save selection for next time


func _file_selected(path: String) -> void:
    if file_mode == EditorFileDialog.FILE_MODE_SAVE_FILE:
        _file_selected_for_saving(path)
    else:
        _file_selected_for_opening(path)


func _file_selected_for_saving(path: String) -> void:
    pass


func _file_selected_for_opening(path: String) -> void:
    pass


func _files_selected(paths: PackedStringArray) -> void:
    pass


func _dir_selected(dir: String) -> void:
    pass


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_TRANSLATION_CHANGED:
            match file_mode:
                EditorFileDialog.FILE_MODE_OPEN_FILE:
                    title = tr("Open Theme Resource")
                EditorFileDialog.FILE_MODE_OPEN_FILES, EditorFileDialog.FILE_MODE_OPEN_ANY:
                    title = tr("Open Theme Resources")
                EditorFileDialog.FILE_MODE_OPEN_DIR:
                    title = tr("Open Theme Resources in Directory")
                EditorFileDialog.FILE_MODE_SAVE_FILE:
                    title = tr("Create Theme Resource")


static func create_open_dialog() -> _Self:
    var dialog := _Self.new()
    dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    return dialog


static func create_save_dialog() -> _Self:
    var dialog := _Self.new()
    return dialog
