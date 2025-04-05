@tool
extends VBoxContainer


enum Mode {
    NONE = -1,
    THEME = 0,
    THEME_TYPE = 1,
    DATA_TYPE = 2,
    THEME_ITEM = 3
}

const ThemeUtil := preload("../../theme_util.gd")
const EditorThemeUtil := preload("../../editor_theme_util.gd")

@onready var _hierarchy_button := get_node("Header/HierarchyButton") as OptionButton

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
    _hierarchy_button.clear()
    for mode in range(_mode, -1, -1):
        var idx := _hierarchy_button.item_count
        _hierarchy_button.add_item("")
        _hierarchy_button.set_item_metadata(idx, mode)
        
        match mode:
            Mode.THEME:
                var icon := EditorThemeUtil.get_theme_icon(_theme)
                var text := EditorThemeUtil.get_theme_name(_theme)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, text)
            Mode.THEME_TYPE:
                var icon := EditorThemeUtil.get_theme_type_icon(_theme_type)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, _theme_type)
            Mode.DATA_TYPE:
                var icon := EditorThemeUtil.get_data_type_icon(_data_type)
                var text := EditorThemeUtil.get_data_type_name(_data_type)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, text)
            Mode.THEME_ITEM:
                var icon := EditorThemeUtil.get_data_type_icon(_data_type)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, _theme_item)
