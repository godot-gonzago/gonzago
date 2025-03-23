@tool
extends Tree


var _theme: Theme = null


func _init() -> void:
    # Setup control
    hide_root = true
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    # Setup initial tree
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
    if NodeUtil.is_node_being_edited(self):
        return
    
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
    
    var types_stack := []
    types_stack.push_back(types)
    types_stack.push_back(types_root)
    while not types_stack.is_empty():
        var types_parent: TreeItem = types_stack.pop_back() as TreeItem
        var types_list: PackedStringArray = types_stack.pop_back() as PackedStringArray
        
        types_list.sort()
        for type in types_list:
            var type_item := types_parent.create_child()
            type_item.set_text(0, type)
            type_item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
            var variations := _theme.get_type_variation_list(type)
            
            types_stack.push_back(variations)
            types_stack.push_back(type_item)
            
    if is_inside_tree():
        _update_tree()


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
    
    var types_stack: Array[TreeItem] = []
    types_stack.push_back(types_root)
    while not types_stack.is_empty():
        var types_parent: TreeItem = types_stack.pop_back() as TreeItem
        
        for types_child in types_parent.get_children():
            var type := types_child.get_text(0)
            var icon := types_fallback_icon
            if has_theme_icon(type, "EditorIcons"):
                icon = get_theme_icon(type, "EditorIcons")
            types_child.set_icon(0, icon)
            
            types_stack.push_back(types_child)
