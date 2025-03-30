@tool
@static_unload
extends RefCounted
## Utility for GUI theme.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Theme methods


static func is_base_theme(theme: Theme) -> bool:
    if theme.resource_path: return false
    if Engine.is_editor_hint():
        if theme == EditorInterface.get_editor_theme():
            return true
    return theme == ThemeDB.get_default_theme()


# TODO
static func get_theme_meta_data(
    theme: Theme,
    include_base_theme := true # TODO:
) -> Dictionary:
    return {}

#endregion


#region Data type methods

const _DATA_TYPE_INFO: Dictionary[Theme.DataType, Dictionary] = {
    Theme.DATA_TYPE_COLOR: {
        &"name": &"Colors",
        &"property_path": &"colors",
        &"tags": [&"colors"],
        &"icon_name": &"Color",
        &"icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_CONSTANT: {
        &"name": &"Constants",
        &"property_path": &"constants",
        &"tags": [&"constants"],
        &"icon_name": &"MemberConstant",
        &"icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_FONT: {
        &"name": &"Fonts",
        &"property_path": &"font",
        &"tags": [&"fonts"],
        &"icon_name": &"FontItem",
        &"icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_FONT_SIZE: {
        &"name": &"Font sizes",
        &"property_path": &"font_sizes",
        &"tags": [&"fonts", &"sizes"],
        &"icon_name": &"FontSize",
        &"icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_ICON: {
        &"name": &"Icons",
        &"property_path": &"icons",
        &"tags": [&"icons"],
        &"icon_name": &"ImageTexture",
        &"icon_type": &"EditorIcons"
    },
    Theme.DATA_TYPE_STYLEBOX: {
        &"name": &"StyleBoxes",
        &"property_path": &"styles",
        &"tags": [&"styles", &"boxes"],
        &"icon_name": &"StyleBoxFlat",
        &"icon_type": &"EditorIcons"
    },
}


static func get_data_type_name(data_type: Theme.DataType) -> StringName:
    if _DATA_TYPE_INFO.has(data_type):
        return _DATA_TYPE_INFO[data_type][&"name"]
    return StringName()


static func get_data_type_property_path(data_type: Theme.DataType) -> StringName:
    if _DATA_TYPE_INFO.has(data_type):
        return _DATA_TYPE_INFO[data_type][&"property_path"]
    return StringName()


static func get_data_type_from_property_path(property_path: StringName) -> Theme.DataType:
    for data_type in Theme.DATA_TYPE_MAX:
        if _DATA_TYPE_INFO.has(data_type):
            return _DATA_TYPE_INFO[data_type].get(&"property_path", -1)
    return -1


static func get_data_type_override_property_path(data_type: Theme.DataType) -> StringName:
    if _DATA_TYPE_INFO.has(data_type):
        return StringName("theme_override_%s" % _DATA_TYPE_INFO[data_type][&"property_path"])
    return StringName()


static func get_data_type_tags(data_type: Theme.DataType) -> Array[StringName]:
    if _DATA_TYPE_INFO.has(data_type):
        return _DATA_TYPE_INFO[data_type][&"tags"].duplicate()
    return []


static func get_data_type_icon(data_type: Theme.DataType) -> Texture2D:
    if not _DATA_TYPE_INFO.has(data_type):
        return ThemeDB.fallback_icon

    var icon_name: StringName = _DATA_TYPE_INFO[data_type][&"icon_name"]
    var icon_type: StringName = _DATA_TYPE_INFO[data_type][&"icon_type"]

    if Engine.is_editor_hint():
        var editor_theme := EditorInterface.get_editor_theme()
        if editor_theme.has_icon(icon_name, icon_type):
            return editor_theme.get_icon(icon_name, icon_type)

    var theme := ThemeDB.get_default_theme()
    if theme.has_icon(icon_name, icon_type):
        return theme.get_icon(icon_name, icon_type)

    return ThemeDB.fallback_icon


# TODO
static func get_data_type_meta_data(
    theme: Theme,
    base_theme: Theme,
    data_type: Theme.DataType,
    include_base_theme := true # TODO:
) -> Dictionary:
    return {}

#endregion

#region Theme type methods

static func get_theme_type_icon(theme_type: StringName) -> Texture2D:
    var theme: Theme
    if Engine.is_editor_hint(): theme = EditorInterface.get_editor_theme()
    else: theme = ThemeDB.get_default_theme()
    if theme.has_icon(theme_type, &"EditorIcons"):
        return theme.get_icon(theme_type, &"EditorIcons")
    return theme.get_icon(&"NodeDisabled", &"EditorIcons")


static func get_type_list(
    theme: Theme,
    with_variations := false,
    include_base_theme := true,
    sort := true
) -> PackedStringArray:
    var types := PackedStringArray(theme.get_type_list())

    if not with_variations:
        for idx in range(types.size() - 1, -1, -1):
            var type := types[idx]
            if theme.get_type_variation_base(type):
                types.remove_at(idx)

    if include_base_theme and theme.resource_path:
        var base_theme := ThemeDB.get_default_theme()
        var base_types := base_theme.get_type_list()
        for base_type in base_types:
            if not with_variations and base_theme.get_type_variation_base(base_type):
                continue
            if base_type not in types:
                types.append(base_type)

    if sort: types.sort()
    return types


static func get_type_variation_list(
    theme: Theme,
    base_type: StringName,
    include_base_theme := true,
    sort := true
) -> PackedStringArray:
    var variations := PackedStringArray(theme.get_type_variation_list(base_type))

    if include_base_theme and theme.resource_path:
        var base_theme := ThemeDB.get_default_theme()
        var base_variations := base_theme.get_type_variation_list(base_type)
        for base_variation in base_variations:
            if base_variation not in variations:
                variations.append(base_variation)

    if sort: variations.sort()
    return variations


static func has_type(
    theme: Theme,
    theme_type: StringName,
    include_base_theme := false
) -> bool:
    if theme_type in theme.get_type_list():
        return true
    if include_base_theme and theme.resource_path:
        var base_theme := ThemeDB.get_default_theme()
        return theme_type in base_theme.get_type_list()
    return false


# TODO
static func get_theme_type_meta_data(
    theme: Theme,
    base_theme: Theme,
    theme_type: StringName,
    include_base_theme := true # TODO:
) -> Dictionary:
    return {}

#endregion

#region Theme item methods

# Can be used as id
static func get_theme_item_path(
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName
) -> StringName:
    return StringName("%s/%s/%s" % [
        theme_type, get_data_type_property_path(data_type), name
    ])


static func get_theme_item_list(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    include_base_type := true,
    include_base_theme := true,
    sort := true
) -> PackedStringArray:
    var items := PackedStringArray(theme.get_theme_item_list(data_type, theme_type))

    if include_base_type:
        var base_type := theme.get_type_variation_base(theme_type)
        var base_type_items := theme.get_theme_item_list(data_type, base_type)
        for item in base_type_items:
            if item not in items:
                items.append(item)

    if include_base_theme and theme.resource_path:
        var base_theme := ThemeDB.get_default_theme()
        var base_theme_items := base_theme.get_theme_item_list(data_type, theme_type)
        for item in base_theme_items:
            if item not in items:
                items.append(item)

        if include_base_type:
            var base_type := base_theme.get_type_variation_base(theme_type)
            var base_type_items := base_theme.get_theme_item_list(data_type, base_type)
            for item in base_type_items:
                if item not in items:
                    items.append(item)

    if sort: items.sort()
    return items


static func has_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    include_base_type := false,
    include_base_theme := false
) -> bool:
    if theme.has_theme_item(data_type, name, theme_type):
        return true

    if include_base_type:
        var base_type := theme.get_type_variation_base(theme_type)
        if theme.has_theme_item(data_type, name, base_type):
            return true

    if include_base_theme and theme.resource_path:
        var base_theme := ThemeDB.get_default_theme()
        if base_theme.has_theme_item(data_type, name, theme_type):
            return true

        if include_base_type:
            var base_type := base_theme.get_type_variation_base(theme_type)
            if base_theme.has_theme_item(data_type, name, base_type):
                return true

    return false


static func is_built_in_type(type: StringName, max_api_depth := ClassDB.API_EDITOR) -> bool:
    var api_type := ClassDB.class_get_api_type(type)
    return api_type <= max_api_depth


# TODO Build meta data for theme item, eg. icon width, height and resource location (path/embedded) etc.
static func get_theme_item_meta_data(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    include_base_type := true, # TODO:
    include_base_theme := true # TODO:
) -> Dictionary:
    return {}

#endregion
