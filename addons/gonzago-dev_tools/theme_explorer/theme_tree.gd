@tool
extends Tree


var _theme: Theme = null


func _init() -> void:
    var root := create_item()

    var theme_root := root.create_child()
    theme_root.set_text(0, tr("Theme"))
    theme_root.set_selectable(0, false)
    theme_root.set_editable(0, false)
    theme_root.create_child().set_text(0, tr("Properties"))
    theme_root.create_child().set_text(0, tr("Statistics"))
    theme_root.create_child().set_text(0, tr("Resources"))

    var data_root := root.create_child()
    data_root.set_text(0, tr("Data"))
    data_root.set_selectable(0, false)
    data_root.set_editable(0, false)
    for data_type in Theme.DATA_TYPE_MAX:
        var item := data_root.create_child()
        item.set_text(0, ThemeUtil.get_data_type_name(data_type))

    var types_root := root.create_child()
    types_root.set_text(0, tr("Types"))
    types_root.set_selectable(0, false)
    types_root.set_editable(0, false)


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_THEME_CHANGED:
            _update_tree()


func inspect(t: Theme) -> void:
    _build_tree(t)


func _build_tree(t: Theme) -> void:
    if _theme == t:
        push_warning("Already inspecting theme!")
        return

    _theme = t

    var types_root := get_root().get_child(2)
    for type_item in types_root.get_children():
        type_item.free()

    if not _theme:
        push_error("Theme was null!")
        return

    var types := PackedStringArray()
    for type in _theme.get_type_list():
        if _theme.get_type_variation_base(type).is_empty():
            types.append(type)
    _build_types(types_root, types)


func _build_types(root: TreeItem, types: PackedStringArray) -> void:
    types.sort()
    for type in types:
        var type_item := root.create_child()
        type_item.set_text(0, type)
        type_item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
        var variations := _theme.get_type_variation_list(type)
        _build_types(type_item, variations)


func _update_tree() -> void:
    if not is_inside_tree():
        push_error("Can't update icons when not inside SceneTree!")
        return
    var root := get_root()
    if not root:
        push_error("Tree has not been built!")
        return

    var section_color := get_theme_color("prop_subsection", "Editor")

    var theme_icon := get_theme_icon("Theme", "EditorIcons")
    var theme_root := root.get_child(0)
    theme_root.set_icon(0, theme_icon)
    theme_root.set_custom_bg_color(0, section_color)
    theme_root.get_child(0).set_icon(0, get_theme_icon("Tools", "EditorIcons"))
    theme_root.get_child(1).set_icon(0, get_theme_icon("NodeInfo", "EditorIcons"))
    theme_root.get_child(2).set_icon(0, get_theme_icon("Object", "EditorIcons"))

    var data_icon := get_theme_icon("Groups", "EditorIcons")
    var data_root := root.get_child(1)
    data_root.set_icon(0, data_icon)
    data_root.set_custom_bg_color(0, section_color)
    for data_type in Theme.DATA_TYPE_MAX:
        var item := data_root.get_child(data_type)
        item.set_icon(
            0,
            ThemeUtil.get_data_type_icon(data_type)
        )

    var types_icon := get_theme_icon("ClassList", "EditorIcons")
    var types_root := root.get_child(2)
    types_root.set_icon(0, types_icon)
    types_root.set_custom_bg_color(0, section_color)

    var types_fallback_icon := get_theme_icon("NodeDisabled", "EditorIcons")
    _update_types(types_root, types_fallback_icon)


func _update_types(root: TreeItem, root_icon: Texture2D) -> void:
    for item in root.get_children():
        var type := item.get_text(0)
        var icon := root_icon
        if has_theme_icon(type, "EditorIcons"):
            icon = get_theme_icon(type, "EditorIcons")
        item.set_icon(0, icon)
        _update_types(item, root_icon)
