@tool
extends VBoxContainer

const NodeUtil := Gonzago.NodeUtil

@onready var _filter := get_node("%Filter") as LineEdit
@onready var _list := get_node("%IconsList") as ItemList


func _notification(what: int) -> void:
    if NodeUtil.is_node_being_edited(self):
        return

    match what:
        NOTIFICATION_READY:
            _update_theme()
            _on_icons_list_resized()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _update_theme()
                _on_icons_list_resized()


func _update_theme() -> void:
    _filter.right_icon = get_theme_icon(&"Search", &"EditorIcons")

    _list.clear()

    var editor_theme := EditorInterface.get_editor_theme()
    var icon_size := editor_theme.get_constant(&"class_icon_size", &"Editor")
    _list.fixed_icon_size = Vector2(icon_size, icon_size)

    var items := editor_theme.get_icon_list(&"EditorIcons")
    items.sort()

    for item in items:
        var icon := editor_theme.get_icon(item, &"EditorIcons")
        if icon.get_width() != icon_size or icon.get_height() != icon_size:
            continue
        _list.add_item(item, icon)
        _list.set_item_tooltip(-1, "%s,\n%s" % [item, &"EditorIcons"])


func _on_icons_list_resized() -> void:
    if NodeUtil.is_node_being_edited(self) or not is_node_ready():
        return

    var editor_theme := EditorInterface.get_editor_theme()

    var panel := get_theme_stylebox(&"panel", &"ItemList")
    var panel_margin := panel.content_margin_left + panel.content_margin_right
    var scroll_width := _list.get_h_scroll_bar().get_combined_minimum_size().x
    var full_width := _list.size.x - panel_margin - scroll_width

    var thumb_size := editor_theme.get_constant(&"thumb_size", &"Editor")
    var h_separation := get_theme_constant(&"h_separation", &"ItemList")

    var columns := maxi(
        1,
        floori((full_width + h_separation) / (thumb_size + h_separation))
    )
    _list.max_columns = columns

    var column_width := maxf(
        thumb_size,
        (full_width / columns) - h_separation
    )
    _list.fixed_column_width = column_width
