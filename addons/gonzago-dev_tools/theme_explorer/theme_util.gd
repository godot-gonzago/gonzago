@tool
@static_unload
extends RefCounted
## Utility for GUI theme.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Themes

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
    
    
static func is_readonly(theme: Theme) -> bool:
    if Engine.is_editor_hint():
        if theme == EditorInterface.get_editor_theme():
            return true
    if theme == ThemeDB.get_default_theme():
        return true
    return false


static func is_project_theme(theme: Theme) -> bool:
    if not theme or not theme.resource_path: return false
    return theme == ThemeDB.get_project_theme()


# TODO:
static func has_default_base_scale(theme: Theme, include_defaults := false) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if base_theme.has_default_base_scale():
            return true
    return false

# TODO:
static func get_default_base_scale(theme: Theme, include_defaults := true) -> float:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if base_theme.has_default_base_scale():
            return base_theme.default_base_scale
    return ThemeDB.fallback_base_scale

# TODO:
static func has_default_font(theme: Theme, include_defaults := false) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if base_theme.has_default_font():
            return true
    return false

# TODO:
static func get_default_font(theme: Theme, include_defaults := true) -> Font:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if base_theme.has_default_font():
            return base_theme.default_font
    return ThemeDB.fallback_font
    
# TODO:
static func has_default_font_size(theme: Theme, include_defaults := false) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if base_theme.has_default_font_size():
            return true
    return false

# TODO:
static func get_default_font_size(theme: Theme, include_defaults := true) -> int:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        if base_theme.has_default_font_size():
            return base_theme.default_font_size
    return ThemeDB.fallback_font_size

#endregion

#region Data types

static func get_data_type_property_path(data_type: Theme.DataType) -> StringName:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return &"colors"
        Theme.DATA_TYPE_CONSTANT:  return &"constants"
        Theme.DATA_TYPE_FONT:      return &"font"
        Theme.DATA_TYPE_FONT_SIZE: return &"font_sizes"
        Theme.DATA_TYPE_ICON:      return &"icons"
        Theme.DATA_TYPE_STYLEBOX:  return &"styles"
        _:                         return StringName()


static func get_data_type_from_property_path(property_path: StringName) -> Theme.DataType:
    if property_path:
        property_path = property_path.trim_prefix("theme_override_")
    match property_path:
        &"colors":     return Theme.DATA_TYPE_COLOR
        &"constants":  return Theme.DATA_TYPE_CONSTANT
        &"font":       return Theme.DATA_TYPE_FONT
        &"font_sizes": return Theme.DATA_TYPE_FONT_SIZE
        &"icons":      return Theme.DATA_TYPE_ICON
        &"styles":     return Theme.DATA_TYPE_STYLEBOX
        _:             return -1


static func get_data_type_override_property_path(data_type: Theme.DataType) -> StringName:
    var property_path := get_data_type_property_path(data_type)
    if property_path:
        return "theme_override_%s" % property_path
    return StringName("")


static func get_data_type_fallback(data_type: Theme.DataType) -> Variant:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return Color.BLACK
        Theme.DATA_TYPE_CONSTANT:  return 0
        Theme.DATA_TYPE_FONT:      return ThemeDB.fallback_font
        Theme.DATA_TYPE_FONT_SIZE: return ThemeDB.fallback_font_size
        Theme.DATA_TYPE_ICON:      return ThemeDB.fallback_icon
        Theme.DATA_TYPE_STYLEBOX:  return ThemeDB.fallback_stylebox
        _:                         return null
        
        
static func is_valid_value_for_data_type(
    data_type: Theme.DataType,
    value: Variant
) -> bool:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return typeof(value) == TYPE_COLOR
        Theme.DATA_TYPE_CONSTANT:  return typeof(value) == TYPE_INT
        Theme.DATA_TYPE_FONT:      return value is Font
        Theme.DATA_TYPE_FONT_SIZE: return typeof(value) == TYPE_INT
        Theme.DATA_TYPE_ICON:      return value is Texture2D
        Theme.DATA_TYPE_STYLEBOX:  return value is StyleBox
        _:                         return false

#endregion

#region Theme types

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


static func is_built_in_type(type: StringName, max_api_depth := ClassDB.API_EDITOR_EXTENSION) -> bool:
    var api_type := ClassDB.class_get_api_type(type)
    return api_type <= max_api_depth

#endregion

#region Theme items

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
    

# TODO:
static func set_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    value: Variant
) -> void:
    if not is_valid_value_for_data_type(data_type, value):
        value = get_data_type_fallback(data_type)
    theme.set_theme_item(data_type, name, theme_type, value)


# TODO:
static func clear_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName
) -> void:
    if theme.has_theme_item(data_type, name, theme_type):
        theme.clear_theme_item(data_type, name, theme_type)
        

# TODO:
static func rename_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    old_name: StringName,
    name: StringName,
    include_defaults := true
) -> void:
    if theme.has_theme_item(data_type, name, theme_type):
        theme.clear_theme_item(data_type, name, theme_type)
    if not theme.has_theme_item(data_type, old_name, theme_type):
        var value := get_theme_item(theme, data_type, theme_type, old_name, include_defaults)
        theme.set_theme_item(data_type, name, theme_type, value)
        return
    theme.rename_theme_item(data_type, old_name, name, theme_type)


#endregion

#region Colors

static func has_color(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_color(name, base_type):
                return true
    return false


static func get_color(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> Color:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_color(name, base_type):
                return base_theme.get_color(name, base_type)
    return Color.BLACK

#endregion

#region Constants

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
static var _constant_type_regex := RegEx.create_from_string(
    r"(?(DEFINE)" + \
    r"(?P<p>size|height|width|margin|padding|separation|offset|spacing|thickness|border)" + \
    r"(?P<ps>bottom|top|left|right|x|y)" + \
    r"(?P<f>scale|speed)" + \
    r"(?P<b>draw|modulate|align|center))" + \
    r"^(?:(?P<pixel>(?:\w+_)*(?P>p)(?:_(?P>ps))?)|(?P<factor>(?:\w+_)*(?P>f))|(?P<flag>(?P>b)(?:_\w+)*))$"
)


static func get_constant_type(name: StringName) -> ConstantType:
    var regex_match := _constant_type_regex.search(name)
    if regex_match and regex_match.get_group_count() > 0:
        if regex_match.names.has("pixel"):
            return ConstantType.PIXEL
        elif regex_match.names.has("factor"):
            return ConstantType.FACTOR
        elif regex_match.names.has("flag"):
            return ConstantType.FLAG
    return ConstantType.UNKNOWN


static func has_constant(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_constant(name, base_type):
                return true
    return false


static func get_constant(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> int:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_constant(name, base_type):
                return base_theme.get_constant(name, base_type)
    return 0

#endregion

#region Fonts

static func has_font(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_font(name, base_type):
                return true
    return false


static func get_font(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> Font:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_font(name, base_type):
                return base_theme.get_font(name, base_type)
    return ThemeDB.fallback_font

#endregion

#region Font sizes

static func has_font_size(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_font_size(name, base_type):
                return true
    return false


static func get_font_size(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> int:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_font_size(name, base_type):
                return base_theme.get_font_size(name, base_type)
    return ThemeDB.fallback_font_size

#endregion

#region Icons

static func has_icon(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_color(name, base_type):
                return true
    return false


static func get_icon(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> Texture2D:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_icon(name, base_type):
                return base_theme.get_icon(name, base_type)
    return ThemeDB.fallback_icon

#endregion

#region StyleBoxes

static func has_stylebox(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_stylebox(name, base_type):
                return true
    return false


static func get_stylebox(
    theme: Theme,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> StyleBox:
    for base_theme in ThemeIterator.new(theme, include_defaults):
        for base_type in ThemeTypeIterator.new(base_theme, theme_type, include_defaults):
            if base_theme.has_stylebox(name, base_type):
                return base_theme.get_stylebox(name, base_type)
    return ThemeDB.fallback_stylebox

#endregion
