@tool
extends VBoxContainer

const ThemeUtil := Gonzago.ThemeUtil
const ItemsList := preload("uid://cih5nr6v1i0e2")

signal data_type_selected(data_type: Theme.DataType, theme_type: StringName)
signal theme_item_selected(data_type: Theme.DataType, theme_type: StringName, theme_item: StringName)

@onready var _tree := get_node("Tree") as Tree
@onready var _list := get_node("ItemsList") as ItemsList

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
        item.set_meta(&"theme_type", _theme_type)
        item.set_meta(&"data_type", data_type)

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
        item.set_meta(&"theme_item", theme_item)
        item.set_meta(&"theme_type", _theme_type)
        item.set_meta(&"data_type", data_type)
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
                var value: Color = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_COLOR, theme_item, _theme_type)
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
                var value: int = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_CONSTANT, theme_item, _theme_type)
                item.set_text(1, str(value))
                var constant_type := ThemeUtil.get_constant_type(theme_item)
                item.set_suffix(1, ThemeUtil.get_constant_type_suffix(constant_type))
                # TODO: Remove, only for testing
                if constant_type == ThemeUtil.ConstantType.FLAG:
                    item.set_suffix(1, "flag")
            Theme.DATA_TYPE_FONT:
                item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
                item.set_custom_draw_callback(1, _custom_draw_font)
            Theme.DATA_TYPE_FONT_SIZE:
                var value: int = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_FONT_SIZE, theme_item, _theme_type)
                item.set_text(1, str(value))
                item.set_suffix(1, "pt")
            Theme.DATA_TYPE_ICON:
                var value: Texture2D = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_ICON, theme_item, _theme_type)
                item.set_icon(1, value)
                item.set_icon_max_width(1, 16)
            Theme.DATA_TYPE_STYLEBOX:
                item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
                item.set_editable(1, true)

        if item.visible:
            has_visibile_children = true
    return has_visibile_children


func _custom_draw_font(item: TreeItem, rect: Rect2) -> void:
    var theme_item := item.get_text(0)
    var value: Font = ThemeUtil.get_theme_item(_theme, Theme.DATA_TYPE_FONT, theme_item, _theme_type)

    var sb := get_theme_stylebox(&"normal", &"Button")
    _tree.draw_style_box(sb, rect)
    if item.is_selected:
        var sel_sb := get_theme_stylebox(&"focus", &"Button")
        _tree.draw_style_box(sel_sb, rect)


func _on_tree_custom_item_clicked(mouse_button_index: int) -> void:
    var column := _tree.get_selected_column()
    if column != 1:
        return

    var item := _tree.get_selected()
    var theme_item := item.get_text(0)
    print("Custom Item Clicked: %s" % theme_item)


func _on_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
    var column := _tree.get_column_at_position(mouse_position)
    if column != 1:
        return

    var item := _tree.get_item_at_position(mouse_position)
    var theme_item := item.get_text(0)
    print("Mouse Selected: %s" % theme_item)


func _on_tree_item_edited() -> void:
    var column := _tree.get_edited_column()
    if column != 1:
        return

    var item := _tree.get_edited()
    var theme_item := item.get_text(0)
    print("Editited: %s" % theme_item)


func _on_tree_item_selected() -> void:
    var item := _tree.get_selected()

    var theme_item := item.get_meta(&"theme_item", StringName())
    var theme_type := item.get_meta(&"theme_type", StringName())
    var data_type := item.get_meta(&"data_type", Theme.DATA_TYPE_MAX)

    if theme_item:
        theme_item_selected.emit(data_type, theme_type, theme_item)
    else:
        data_type_selected.emit(data_type, theme_type)

    _tree.queue_redraw()

#region List

enum DisplayMode {
    DISPLAY_MODE_LIST,
    DISPLAY_MODE_THUMBNAIL
}

#endregion
