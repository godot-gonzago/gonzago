@tool
extends Node #EditorFileDialog

# EditorFileDialog:
# https://docs.godotengine.org/en/stable/classes/class_editorfiledialog.html
# - use_native_dialog via EditorSettings.interface/editor/use_native_file_dialogs
# - var disable_overwrite_warning: bool = false
# - var display_mode: EditorFileDialog.DisplayMode = EditorFileDialog.DisplayMode.DISPLAY_THUMBNAILS
# - func get_filename_filter() -> String: pass
# - func add_side_menu(menu: Control, title: String = "") -> void: pass
# - func popup_file_dialog() -> void: pass
#
# FileDialog:
# https://docs.godotengine.org/en/stable/classes/class_filedialog.html#class-filedialog
# - @export var mode_overrides_title: bool = true
# - @export var filename_filter: String = ""
# - @export var root_subfolder: String = ""
# - @export var use_native_dialog: bool = false
# - func deselect_all() -> void: pass
# - var ok_button_text: String = "Save" # (overrides AcceptDialog)
# - var size: Vector2i = Vector2i(640, 360) # (overrides Window)
# - Theme overrides?
#
# Overlap:
# - signal dir_selected(dir: String)
# - signal file_selected(path: String)
# - signal filename_filter_changed(filter: String)
# - signal files_selected(paths: PackedStringArray)
# - @export var file_mode: FileDialog.FileMode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
# - @export var access: FileDialog.Access = FileDialog.Access.ACCESS_RESOURCES
# - @export var filters: PackedStringArray = []
# - @export var show_hidden_files: bool = false
# - var current_dir: String
# - var current_file: String
# - var current_path: String
# - var dialog_hide_on_ok: bool = false # (overrides AcceptDialog)
# - var title: String = "Save a File" # (overrides Window)
# - func add_filter(filter: String, description: String = "") -> void: pass
# - func clear_filters() -> void: pass
# - func clear_filename_filter() -> void: pass
# - var option_count: int = 0
# - func add_option(name: String, values: PackedStringArray, default_value_index: int) -> void: pass
# - func get_option_default(option: int) -> int: pass
# - func set_option_default(option: int, default_value_index: int) -> void: pass
# - func get_option_name(option: int) -> String: pass
# - func set_option_name(option: int, name: String) -> void: pass
# - func get_option_values(option: int) -> PackedStringArray: pass
# - func set_option_values(option: int, values: PackedStringArray) -> void: pass
# - func get_selected_options() -> Dictionary: pass
# - func invalidate() -> void: pass
# - func get_line_edit() -> LineEdit: pass
# - func get_vbox() -> VBoxContainer: pass

signal dir_selected(dir: String)
signal file_selected(path: String)
signal filename_filter_changed(filter: String)
signal files_selected(paths: PackedStringArray)

@export var base_type := "Resource"
@export var file_mode := FileDialog.FileMode.FILE_MODE_SAVE_FILE
@export var access := FileDialog.Access.ACCESS_RESOURCES
@export var show_hidden_files: bool = false

var current_dir: String
var current_file: String
var current_path: String

var _dialog: ConfirmationDialog


func _init() -> void:
    if Engine.is_editor_hint():
        _dialog = EditorFileDialog.new()
    else:
        _dialog = FileDialog.new()

# - func add_filter(filter: String, description: String = "") -> void: pass
# - func clear_filters() -> void: pass
# - func clear_filename_filter() -> void: pass

# - func add_option(name: String, values: PackedStringArray, default_value_index: int) -> void: pass
# - func get_option_default(option: int) -> int: pass
# - func set_option_default(option: int, default_value_index: int) -> void: pass
# - func get_option_name(option: int) -> String: pass
# - func set_option_name(option: int, name: String) -> void: pass
# - func get_option_values(option: int) -> PackedStringArray: pass
# - func set_option_values(option: int, values: PackedStringArray) -> void: pass
# - func get_selected_options() -> Dictionary: pass
# - func invalidate() -> void: pass
# - func popup_file_dialog() -> void: pass
