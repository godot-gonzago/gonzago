@tool
@static_unload
extends RefCounted
## Utility for GUI theme.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Theme methods

# https://forum.godotengine.org/t/deep-er-dive-on-godot-custom-iterators-and-the-mysterious-arg/92474
class ThemeIterator extends RefCounted:
    var _theme: Theme
    var _include_base_theme: bool
    
    func _init(theme: Theme, include_base_theme := true) -> void:
        if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
            _theme = theme
            _include_base_theme = false
            return
        
        _theme = theme
        _include_base_theme = include_base_theme
        
    func _iter_init(iter: Array) -> bool:
        iter[0] = _theme
        return is_instance_valid(_theme)
        
    func _iter_next(iter: Array) -> bool:
        var theme := iter[0] as Theme
        if not theme or not _include_base_theme:
            iter[0] = null
            return false
        
        var default_theme := ThemeDB.get_default_theme()
        if theme == default_theme:
            iter[0] = null
            return false
        
        var project_theme := ThemeDB.get_project_theme()
        if project_theme and not theme == project_theme:
            iter[0] = project_theme
            return true
        
        iter[0] = default_theme
        return true
        
    func _iter_get(current: Variant) -> Theme:
        return current as Theme


static func has_base_theme(theme: Theme) -> bool:
    if theme and theme.resource_path: return true
    if Engine.is_editor_hint():
        if theme == EditorInterface.get_editor_theme():
            return false
    return theme != ThemeDB.get_default_theme()


static func get_base_theme(theme: Theme) -> Theme:
    if Engine.is_editor_hint():
        if theme == EditorInterface.get_editor_theme():
            return null
    
    var default_theme := ThemeDB.get_default_theme()
    if theme == default_theme:
        return null
    
    var project_theme := ThemeDB.get_project_theme()
    if project_theme and not theme == project_theme:
        return project_theme

    return default_theme


static func has_project_theme() -> bool:
    var project_theme := ThemeDB.get_project_theme()
    return is_instance_valid(project_theme)


static func is_project_theme(theme: Theme) -> bool:
    if not theme or not theme.resource_path: return false
    return theme == ThemeDB.get_project_theme()


# TODO
static func get_theme_meta_data(
    theme: Theme,
    include_defaults := true # TODO:
) -> Dictionary:
    return {}

#endregion


#region Data type methods

const _FALLBACK_COLOR := Color.WHITE
const _FALLBACK_CONSTANT := 0

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


# TODO: Fix
#static func get_data_type_from_property_path(property_path: StringName) -> Theme.DataType:
    #for data_type in Theme.DATA_TYPE_MAX:
        #if _DATA_TYPE_INFO.has(data_type):
            #return _DATA_TYPE_INFO[data_type].get(&"property_path", -1)
    #return -1


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


static func get_data_type_fallback(data_type: Theme.DataType) -> Variant:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return _FALLBACK_COLOR
        Theme.DATA_TYPE_CONSTANT:  return _FALLBACK_CONSTANT
        Theme.DATA_TYPE_FONT:      return ThemeDB.fallback_font
        Theme.DATA_TYPE_FONT_SIZE: return ThemeDB.fallback_font_size
        Theme.DATA_TYPE_ICON:      return ThemeDB.fallback_icon
        Theme.DATA_TYPE_STYLEBOX:  return ThemeDB.fallback_stylebox
        _:                         return null


# TODO
static func get_data_type_meta_data(
    theme: Theme,
    base_theme: Theme,
    data_type: Theme.DataType,
    include_defaults := true # TODO:
) -> Dictionary:
    return {}

#endregion

#region Theme type methods

# https://forum.godotengine.org/t/deep-er-dive-on-godot-custom-iterators-and-the-mysterious-arg/92474
class ThemeTypeIterator extends RefCounted:
    var _theme: Theme
    var _theme_type: StringName
    var _include_base_type := true
    
    func _init(theme: Theme, theme_type: StringName, include_base_type := true) -> void:
        _theme = theme
        _theme_type = theme_type
        _include_base_type = include_base_type
        
    func _iter_init(iter: Array) -> bool:
        iter[0] = _theme_type
        if not _theme_type: return false
        return true
        
    func _iter_next(iter: Array) -> bool:
        var theme_type := iter[0] as StringName
        if not theme_type or not _include_base_type:
            iter[0] = StringName("")
            return false
        
        if not _theme:
            iter[0] = StringName("")
            return false
        
        var base_type := _theme.get_type_variation_base(theme_type)
        if not base_type:
            iter[0] = StringName("")
            return false
        
        iter[0] = base_type
        return true
        
    func _iter_get(current: Variant) -> StringName:
        return current as StringName


static func get_theme_type_icon(theme_type: StringName) -> Texture2D:
    var theme: Theme
    if Engine.is_editor_hint(): theme = EditorInterface.get_editor_theme()
    else: theme = ThemeDB.get_default_theme()
    if theme.has_icon(theme_type, &"EditorIcons"):
        return theme.get_icon(theme_type, &"EditorIcons")
    return theme.get_icon(&"NodeDisabled", &"EditorIcons")


static func get_type_list(
    theme: Theme,
    include_variations := false,
    include_defaults := true,
    sort := true
) -> PackedStringArray:
    var types := PackedStringArray()

    for base_theme in ThemeIterator.new(theme, include_defaults):
        var base_types := base_theme.get_type_list()
        for base_type in base_types:
            if not include_variations and base_theme.get_type_variation_base(base_type):
                continue
            if base_type not in types:
                types.append(base_type)

    if sort: types.sort()
    return types


static func get_type_variation_list(
    theme: Theme,
    base_type: StringName,
    include_defaults := true,
    sort := true
) -> PackedStringArray:
    var variations := PackedStringArray()

    for base_theme in ThemeIterator.new(theme, include_defaults):
        var base_variations := base_theme.get_type_variation_list(base_type)
        for base_variation in base_variations:
            if base_variation not in variations:
                variations.append(base_variation)

    if sort: variations.sort()
    return variations


static func has_type(
    theme: Theme,
    theme_type: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if theme_type in base_theme.get_type_list():
            return true
    return false


static func is_built_in_type(type: StringName, max_api_depth := ClassDB.API_EDITOR) -> bool:
    var api_type := ClassDB.class_get_api_type(type)
    return api_type <= max_api_depth


# TODO
static func get_theme_type_meta_data(
    theme: Theme,
    base_theme: Theme,
    theme_type: StringName,
    include_defaults := true # TODO:
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
    include_defaults := true,
    sort := true
) -> PackedStringArray:
    var items := PackedStringArray()

    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
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
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_theme_item(data_type, name, base_type):
                return true
    return false


static func get_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> Variant:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_theme_item(data_type, name, base_type):
                return base_theme.get_theme_item(data_type, name, base_type)
    return get_data_type_fallback(data_type)

# TODO: Add data type functions get_icon, has_icon etc.


# TODO Build meta data for theme item, eg. icon width, height and resource location (path/embedded) etc.
static func get_theme_item_meta_data(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    include_defaults := true # TODO:
) -> Dictionary:
    return {}

#endregion

#region Constant methods

enum ConstantType {
    UNKNOWN = -1,
    PIXEL = 0,
    FACTOR = 1,
    FLAG = 2
}

# https://regex101.com/r/2vR47X/1
# TODO: Guess format
#       name ends with:
#       px: size, height, width, margin, padding,
#           separation, offset, spacing, thickness, border
#           with optional prefix: h_, v_ (does not need checking)
#           with optional suffix: _bottom, _top, _left, _right, _x, _y
#       factor: scale, speed
#       bool: if value is 0 or 1 (but only guessing)
#             maybe if starts with: draw, modulate, align, center
static var _constant_pixel_regex := RegEx.create_from_string(
    r"(?(DEFINE)" + \
    r"(?P<p>size|height|width|margin|padding|separation|offset|spacing|thickness|border)" + \
    r"(?P<ps>bottom|top|left|right|x|y)" + \
    r"(?P<f>scale|speed)" + \
    r"(?P<b>draw|modulate|align|center))" + \
    r"^(?:(?P<pixel>(?:\w+_)*(?P>p)(?:_(?P>ps))?)|(?P<factor>(?:\w+_)*(?P>f))|(?P<flag>(?P>b)(?:_\w+)*))$"
)


static func get_constant_type(name: StringName) -> ConstantType:
    var regex_match := _constant_pixel_regex.search(name)
    if regex_match and regex_match.get_group_count() > 0:
        if regex_match.names.has("pixel"):
            return ConstantType.PIXEL
        elif regex_match.names.has("factor"):
            return ConstantType.FACTOR
        elif regex_match.names.has("flag"):
            return ConstantType.FLAG
    return ConstantType.UNKNOWN

#endregion
