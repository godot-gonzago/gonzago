@tool
extends RefCounted


static func get_theme_override_group_property() -> Dictionary:
    return {
        "name": "Theme Overrides",
        "type": TYPE_NIL,
        "hint": PROPERTY_HINT_NONE,
        "hint_string": "theme_override_",
        "usage": PROPERTY_USAGE_GROUP
    }


static func is_theme_override_property(property: StringName) -> bool:
    return property and property.begins_with("theme_override_")


static func get_theme_override_property(node: Node, property: StringName) -> Variant:
    if not node is Control or not node is Window:
        return null

    if not property or not property.begins_with("theme_override_"):
        return null

    var split := property.split("/", false, 1)
    if split.size() != 2:
        return null

    var name := split[0]
    var type := split[1].trim_prefix("theme_override_").trim_suffix("s")
    if node.callv("has_theme_%s_override" % type, [name]) as bool:
        return node.callv("get_theme_%s" % type, [name])
    return null


static func set_theme_override_property(node: Node, property: StringName, value: Variant) -> bool:
    if not node is Control or not node is Window:
        return false

    if not property or not property.begins_with("theme_override_"):
        return false

    var split := property.split("/", false, 1)
    if split.size() != 2:
        return false

    var name := split[0]
    var type := split[1].trim_prefix("theme_override_").trim_suffix("s")
    if value == null:
        if node.callv("has_theme_%s_override" % type, [name]) as bool:
            node.call("remove_theme_%s_override" % type, name)
        return true
    node.call("add_theme_%s_override" % type, name, value)
    return true


static func get_theme_override_property_item(
    node: Node,
    data_type: Theme.DataType,
    name: StringName
) -> Dictionary:
    var cls_name := &""
    var type := TYPE_NIL
    var hint := PROPERTY_HINT_NONE
    var hint_string := ""

    match data_type:
        Theme.DATA_TYPE_COLOR:
            name = "theme_override_colors/%s" % name
            type = TYPE_COLOR
        Theme.DATA_TYPE_CONSTANT:
            name = "theme_override_constants/%s" % name
            type = TYPE_INT
            hint = PROPERTY_HINT_RANGE
            hint_string = "-16384,16384"
        Theme.DATA_TYPE_FONT:
            name = "theme_override_fonts/%s" % name
            cls_name = &"Font"
            type = TYPE_OBJECT
            hint = PROPERTY_HINT_RESOURCE_TYPE
            hint_string = "Font"
        Theme.DATA_TYPE_FONT_SIZE:
            name = "theme_override_font_sizes/%s" % name
            type = TYPE_INT
            hint = PROPERTY_HINT_RANGE
            hint_string = "1,256,1,or_greater,suffix:px"
        Theme.DATA_TYPE_ICON:
            name = "theme_override_icons/%s" % name
            cls_name = &"Texture2D"
            type = TYPE_OBJECT
            hint = PROPERTY_HINT_RESOURCE_TYPE
            hint_string = "Texture2D"
        Theme.DATA_TYPE_STYLEBOX:
            name = "theme_override_styles/%s" % name
            cls_name = &"StyleBox"
            type = TYPE_OBJECT
            hint = PROPERTY_HINT_RESOURCE_TYPE
            hint_string = "StyleBox"

    var usage := PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_CHECKABLE
    if has_theme_override(node, data_type, name):
        usage |= PROPERTY_USAGE_CHECKED

    return {
        "name": name, "class_name": cls_name, "type": type,
        "hint": hint, "hint_string": hint_string,
        "usage": usage
    }


static func has_theme_override(node: Node, data_type: Theme.DataType, name: StringName) -> bool:
    if not node is Control or not node is Window:
        return false

    var type: String
    match data_type:
        Theme.DATA_TYPE_COLOR:     type = "color"
        Theme.DATA_TYPE_CONSTANT:  type = "constant"
        Theme.DATA_TYPE_FONT:      type = "font"
        Theme.DATA_TYPE_FONT_SIZE: type = "font_size"
        Theme.DATA_TYPE_ICON:      type = "icon"
        Theme.DATA_TYPE_STYLEBOX:  type = "stylebox"
        _:                        return false
    return node.callv("has_theme_%s_override" % type, [name]) as bool
