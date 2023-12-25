@tool
class_name ThemeUtil
extends RefCounted


# Can be used as id
static func get_theme_item_path(
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName
) -> StringName:
    return StringName("%s/%s/%s" % [
        theme_type, get_data_type_property_path(data_type), name
    ])


const _DATA_TYPE_INFO := {
    Theme.DATA_TYPE_COLOR: {
        "name": &"Colors",
        "property_path": &"colors",
        "tags": [&"colors"],
        "icon_name": &"Color",
        "icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_CONSTANT: {
        "name": &"Constants",
        "property_path": &"constants",
        "tags": [&"constants"],
        "icon_name": &"MemberConstant",
        "icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_FONT: {
        "name": &"Fonts",
        "property_path": &"font",
        "tags": [&"fonts"],
        "icon_name": &"FontItem",
        "icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_FONT_SIZE: {
        "name": &"Font sizes",
        "property_path": &"font_sizes",
        "tags": [&"fonts", &"sizes"],
        "icon_name": &"FontSize",
        "icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_ICON: {
        "name": &"Icons",
        "property_path": &"icons",
        "tags": [&"icons"],
        "icon_name": &"ImageTexture",
        "icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_STYLEBOX: {
        "name": &"StyleBoxes",
        "property_path": &"styles",
        "tags": [&"styles", &"boxes"],
        "icon_name": &"StyleBoxFlat",
        "icon_type": &"EditorIcons"
    },
}

static func get_data_type_name(data_type: Theme.DataType) -> StringName:
        if data_type >= 0 and data_type < Theme.DATA_TYPE_MAX:
            return _DATA_TYPE_INFO[data_type]["name"]
        return StringName()

static func get_data_type_property_path(data_type: Theme.DataType) -> StringName:
    if data_type >= 0 and data_type < Theme.DATA_TYPE_MAX:
        return _DATA_TYPE_INFO[data_type]["property_path"]
    return StringName()

static func get_data_type_override_property_path(data_type: Theme.DataType) -> StringName:
    if data_type >= 0 and data_type < Theme.DATA_TYPE_MAX:
        return StringName("theme_override_%s" % _DATA_TYPE_INFO[data_type]["property_path"])
    return StringName()

static func get_data_type_tags(data_type: Theme.DataType) -> Array[StringName]:
    if data_type >= 0 and data_type < Theme.DATA_TYPE_MAX:
        return _DATA_TYPE_INFO[data_type]._tags.duplicate()
    return []

static func get_data_type_icon(data_type: Theme.DataType) -> Texture2D:
    if data_type < 0 and data_type >= Theme.DATA_TYPE_MAX:
        return null
    var icon_name: StringName = _DATA_TYPE_INFO[data_type]["icon_name"]
    var icon_type: StringName = _DATA_TYPE_INFO[data_type]["icon_type"]
    var theme: Theme = ThemeDB.get_default_theme() if not Engine.is_editor_hint() else EditorInterface.get_editor_theme()
    if theme.has_icon(icon_name, icon_type):
        return theme.get_icon(icon_name, icon_type)
    return ThemeDB.fallback_icon
