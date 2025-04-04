@tool
extends VBoxContainer

const ThemeUtil := preload("../../theme_util.gd")

@onready var _tree := get_node("Tree") as Tree

# TODO: Add Button like Manage Items menu in default Theme Menu
#       Add Data Type entries and remove entries. But as a PopupMenu.

# TODO: Make entries like in default Theme Menu with a preview as the second column

var _theme: Theme = null
var _theme_type: StringName = StringName()


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            #_tree.set_column_expand(0, true)
            if _theme and _theme_type:
                _build_tree()
        NOTIFICATION_THEME_CHANGED:
            if _theme and _theme_type and is_node_ready():
                _update_tree()


func inspect(theme: Theme, theme_type: StringName) -> void:
    _theme = theme
    _theme_type = theme_type
    if is_node_ready():
        _build_tree()


func _build_tree() -> void:
    _tree.clear()
    var root := _tree.create_item()
    for data_type in Theme.DATA_TYPE_MAX:
        var item := root.create_child()
        item.set_text(0, ThemeUtil.get_data_type_name(data_type))
        item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
        item.visible = false

    if not _theme: return
    if not _theme_type: return

    for data_type in Theme.DATA_TYPE_MAX:
        var item := root.get_child(data_type)
        item.visible = _build_types_items(item, data_type)

    _update_tree()


func _build_types_items(parent: TreeItem, data_type: Theme.DataType) -> bool:
    var theme_items := ThemeUtil.get_theme_item_list(_theme, data_type, _theme_type)
    for theme_item in theme_items:
        var item := parent.create_child()
        item.set_text(0, theme_item)
        item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
    return theme_items.size() > 0


func _update_tree() -> void:
    var root := _tree.get_root()
    for data_type in Theme.DATA_TYPE_MAX:
        var item := root.get_child(data_type)
        var icon := ThemeUtil.get_data_type_icon(data_type)
        item.set_icon(0, icon)
        item.visible = _update_types_items(item, data_type)


func _update_types_items(parent: TreeItem, data_type: Theme.DataType) -> bool:
    var has_visibile_children := false
    for item in parent.get_children():
        var theme_item := item.get_text(0)

        item.clear_custom_color(0)
        var font_color := get_theme_color("font_color", "Tree")
        var font_disabled_color := get_theme_color("font_disabled_color", "Tree")
        if not _theme.has_theme_item(data_type, theme_item, _theme_type):
            item.set_custom_color(0, font_disabled_color)

        match data_type:
            Theme.DATA_TYPE_COLOR:
                var value: Color = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_COLOR, _theme_type, theme_item)
                item.set_custom_bg_color(1, value)
                #item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
                # TODO: This is not possible with tree.
                #       https://github.com/godotengine/godot/blob/master/editor/plugins/theme_editor_plugin.cpp#L2448
                #       Original uses HBoxContainer
                #       Merge together with list (only handle stuff inside type, not everything at once).
                #       Handle like FileSystem with display toggle
                #       get_theme_icon("FileList", "EditorIcons")
                #       tr("View items as a list.")
                #       get_theme_icon("FileThumbnail", "EditorIcons")
                #       tr("View items as a grid of thumbnails.")
            Theme.DATA_TYPE_CONSTANT:
                var value: int = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_CONSTANT, _theme_type, theme_item)
                item.set_text(1, str(value))
                var constant_type := ThemeUtil.get_constant_type(theme_item)
                match constant_type:
                    ThemeUtil.ConstantType.PIXEL:
                        item.set_suffix(1, "px")
                    ThemeUtil.ConstantType.FACTOR:
                        item.set_suffix(1, "x")
                    ThemeUtil.ConstantType.FLAG:
                        item.set_suffix(1, "flag")
                    _:
                        item.set_suffix(1, "")

        if item.visible:
            has_visibile_children = true
    return has_visibile_children
