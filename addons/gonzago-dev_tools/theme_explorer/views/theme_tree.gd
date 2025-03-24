@tool
extends Tree


const ThemeUtil := preload("../theme_util.gd")


var _theme: Theme = null


func _init() -> void:
    # Setup control
    hide_root = true
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    # Setup initial tree
    var root := create_item()

    var theme_root := root.create_child()
    theme_root.set_text(0, tr("Theme"))
    theme_root.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
    theme_root.set_selectable(0, false)
    theme_root.set_editable(0, false)
    # TODO: Separate view for meta info of theme. Eg. resources like Styleboxes that are reused in different places. Groups of colors etc.
    #       This view provides additional options like creating a copy based on the resource structure.
    #       Separate statistics page, don't know for what yet.
    #       Properties like default font can be previewed here (similar to data types view)
    var theme_items: PackedStringArray = ["Properties", "Statistics", "Resources"]
    for theme_item in theme_items:
        var item := theme_root.create_child()
        item.set_text(0, tr(theme_item))
        item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)

    var data_root := root.create_child()
    data_root.set_text(0, tr("Data"))
    data_root.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
    # TODO: if data is selected ignore theme types and group them all under the selected data type.
    #       eg. show me all icons in the theme.
    #       Data root shows all data types?
    #       Add a visibility button (for filtering). Sort of like a mute solo button
    #       or in an installer with partial visibility that can toggle all children.
    #       Default everything is visible.
    #       get_theme_icon("GuiVisibilityVisible", "EditorIcons") # open eye
    #       get_theme_icon("GuiVisibilityHidden", "EditorIcons") # closed eye
    #       get_theme_icon("GuiVisibilityXray", "EditorIcons") # half eye
    #       Maybe like in scene view with disabled greyed out?
    data_root.set_selectable(0, false)
    data_root.set_editable(0, false)
    data_root.add_button(0, ThemeDB.fallback_icon)
    for data_type in Theme.DATA_TYPE_MAX:
        var item := data_root.create_child()
        item.set_text(0, ThemeUtil.get_data_type_name(data_type))
        item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)

    var types_root := root.create_child()
    types_root.set_text(0, tr("Types"))
    types_root.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
    # TODO: Filter by theme type. Show only entries based on theme type and its subtypes
    #       Types root shows all types?
    #       Add a visibility button (for filtering). Sort of like a mute solo button
    #       or in an installer with partial visibility that can toggle all children.
    #       Default everything is visible.
    #       get_theme_icon("GuiVisibilityVisible", "EditorIcons") # open eye
    #       get_theme_icon("GuiVisibilityHidden", "EditorIcons") # closed eye
    #       get_theme_icon("GuiVisibilityXray", "EditorIcons") # half eye
    #       Maybe like in scene view with disabled greyed out?
    #       https://docs.godotengine.org/en/stable/classes/class_treeitem.html#class-treeitem-method-set-indeterminate
    #       might be helpful
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

    var visibility_icon := get_theme_icon("GuiVisibilityVisible", "EditorIcons")
    var data_icon := get_theme_icon("Groups", "EditorIcons")
    var data_root := root.get_child(1)
    data_root.set_icon(0, data_icon)
    data_root.set_custom_bg_color(0, section_color)
    data_root.set_button(0, 0, visibility_icon)
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
