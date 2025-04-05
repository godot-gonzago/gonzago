@tool
extends VBoxContainer


enum Mode {
    NONE,
    THEME,
    THEME_TYPE,
    DATA_TYPE,
    THEME_ITEM
}

const ThemeUtil := preload("../../theme_util.gd")

@onready var _label := get_node("Label") as Label

var _mode: Mode = Mode.NONE
var _theme: Theme = null
var _data_type: Theme.DataType = Theme.DATA_TYPE_MAX
var _theme_type: StringName = StringName()
var _theme_item: StringName = StringName()


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            if not NodeUtil.is_node_being_edited(self):
                _update_inspector()


func inspect_theme(theme: Theme) -> void:
    _mode = Mode.THEME if theme else Mode.NONE
    _theme = theme
    if is_node_ready():
        _update_inspector()


func inspect_theme_type(theme: Theme, theme_type: StringName) -> void:
    _mode = Mode.THEME_TYPE
    _theme = theme
    _theme_type = theme_type
    if is_node_ready():
        _update_inspector()


func inspect_data_type(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName
) -> void:
    _mode = Mode.DATA_TYPE
    _theme = theme
    _data_type = data_type
    _theme_type = theme_type
    if is_node_ready():
        _update_inspector()


func inspect_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    theme_item :StringName
) -> void:
    _mode = Mode.THEME_ITEM
    _theme = theme
    _data_type = data_type
    _theme_type = theme_type
    _theme_item = theme_item
    if is_node_ready():
        _update_inspector()


func _update_inspector() -> void:
    match _mode:
        Mode.THEME:
            _label.text = "Theme"
        Mode.THEME_TYPE:
            _label.text = _theme_type
        Mode.DATA_TYPE:
            _label.text = ThemeUtil.get_data_type_name(_data_type)
        Mode.THEME_ITEM:
            _label.text = _theme_item
        _:
            _label.text = ""
