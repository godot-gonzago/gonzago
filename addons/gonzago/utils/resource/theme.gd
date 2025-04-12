@tool
@static_unload
extends RefCounted
## Utility for [Theme] resources.
##
## Provides utility functions for [Theme] resources.
## Most functionality extends the default functions already provided by [Theme]
## but generalizes their use.

# TODO: Document according to
#       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

const _ThemeUtil := preload("./theme.gd")

#region Iterators

## Hierarchical iterator for [Theme] resource.
##
## This iterator allows for iteration over a [Theme] and optionally its base themes.
## If [param include_base_themes] is set to [code]true[/code] the iterator tries
## to find the base themes next. For regular themes this is first the project theme
## if available and then the default theme.
class ThemeIterator extends RefCounted:
    class State extends RefCounted:
        var _theme: Theme
        var _is_base_theme: bool = false
        
        var theme: Theme:
            get: return _theme
        var is_base_theme: bool:
            get: return _is_base_theme
        
        func _init(theme: Theme) -> void:
            _theme = theme
    
    var _initial_theme: Theme
    var _include_base_themes: bool
    
    func _init(theme: Theme, include_base_themes := true) -> void:
        _initial_theme = theme
        _include_base_themes = include_base_themes
        
    func _iter_init(iter: Array) -> bool:
        if not _initial_theme:
            iter[0] = null
            return false
        iter[0] = State.new(_initial_theme)
        return true
        
    func _iter_next(iter: Array) -> bool:
        var state := iter[0] as State
        if not state or not _include_base_themes:
            iter[0] = null
            return false
        
        state._theme = _ThemeUtil.get_base_theme(state.theme)
        if state.theme:
            state._is_base_theme = true
            return true
        
        iter[0] = null
        return false
        
    func _iter_get(current: Variant) -> State:
        return current as State


## Hierarchical iterator for types in [Theme] resources.
##
## This iterator allows for iteration over types in a [Theme] and optionally its base types.
## If [param include_base_types] is set to [code]true[/code] the iterator tries
## to find the base types if the given [param theme_type] is a variation.
## If [param include_base_themes] is set to [code]true[/code] the iterator tries
## to find the base themes next. For regular themes this is first the project theme
## if available and then the default theme.
class ThemeTypeIterator extends RefCounted:
    class State extends RefCounted:
        var _theme: Theme
        var _is_base_theme: bool = false
        var _theme_type: StringName
        var _is_base_type: bool = false
        
        var theme: Theme:
            get: return _theme
        var is_base_theme: bool:
            get: return _is_base_theme
        var theme_type: StringName:
            get: return _theme_type
        var is_base_type: bool:
            get: return _is_base_type
        
        func _init(theme: Theme, theme_type: StringName) -> void:
            _theme = theme
            _theme_type = theme_type
    
    var _initial_theme: Theme
    var _include_base_themes: bool
    var _initial_theme_type: StringName
    var _include_base_types: bool
    
    func _init(
        theme: Theme, theme_type: StringName,
        include_base_themes := true, include_base_types := true
    ) -> void:
        _initial_theme = theme
        _initial_theme_type = theme_type
        _include_base_themes = include_base_themes
        _include_base_types = include_base_types
    
    func _iter_init(iter: Array) -> bool:
        if not _initial_theme or not _initial_theme_type:
            iter[0] = null
            return false
        iter[0] = State.new(_initial_theme, _initial_theme_type)
        return true
    
    func _iter_next(iter: Array) -> bool:
        var state := iter[0] as State
        if not state:
            iter[0] = null
            return false
        
        if _include_base_types:
            state._theme_type = state.theme.get_type_variation_base(state.theme_type)
            if state.theme_type:
                state._is_base_type = true
                return true
        
        if _include_base_themes:
            state._theme = _ThemeUtil.get_base_theme(state.theme)
            if state.theme:
                state._is_base_theme = true
                state._theme_type = _initial_theme_type
                state._is_base_type = false
                return true
        
        iter[0] = null
        return false
        
    func _iter_get(current: Variant) -> State:
        return current as State

#endregion

#region Themes

enum ThemeType {
    NONE = -1,
    MEMORY = 0,
    RESOURCE = 1,
    PROJECT = 2,
    DEFAULT = 3,
    EDITOR = 4
}


static func get_theme_type(theme: Theme) -> ThemeType:
    if not theme:
        return ThemeType.NONE
    
    if theme.resource_path:
        var project_theme := ThemeDB.get_project_theme()
        if project_theme and theme == project_theme:
            return ThemeType.PROJECT
        return ThemeType.RESOURCE
    
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return ThemeType.EDITOR
    
    if theme == ThemeDB.get_default_theme():
        return ThemeType.DEFAULT
    
    return ThemeType.MEMORY


static func has_base_theme(theme: Theme) -> bool:
    if not theme:
        return false
    if theme.resource_path:
        return true
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return false
    return theme != ThemeDB.get_default_theme()


static func get_base_theme(theme: Theme) -> Theme:
    if not theme:
        return null
    
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return null
    
    var default_theme := ThemeDB.get_default_theme()
    if theme == default_theme:
        return null
    
    var project_theme := ThemeDB.get_project_theme()
    if project_theme and not theme == project_theme:
        return project_theme
    
    return default_theme


static func is_built_in_theme(theme: Theme) -> bool:
    if not theme:
        return false
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return true
    if theme == ThemeDB.get_default_theme():
        return true
    return false


static func has_default_base_scale(theme: Theme, include_base_themes := false) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_base_scale(): return true
    return false


static func get_default_base_scale(theme: Theme, include_base_themes := true) -> float:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_base_scale(): return s.theme.default_base_scale
    return ThemeDB.fallback_base_scale
    
    
# TODO: 0.0 will clear
static func set_default_base_scale(theme: Theme, value: float = 0.0) -> void:
    if theme and not is_built_in_theme(theme):
        theme.default_base_scale = maxf(0.0, value)
    
    
static func clear_default_base_scale(theme: Theme) -> void:
    set_default_base_scale(theme, 0.0)


static func has_default_font(theme: Theme, include_base_themes := false) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font(): return true
    return false


static func get_default_font(theme: Theme, include_base_themes := true) -> Font:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font(): return s.theme.default_font
    return ThemeDB.fallback_font


# TODO: null will clear
static func set_default_font(theme: Theme, value: Font = null) -> void:
    if theme and not is_built_in_theme(theme):
        theme.default_font = value
        
        
static func clear_default_font(theme: Theme) -> void:
    set_default_font(theme, null)


static func has_default_font_size(theme: Theme, include_base_themes := false) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font_size(): return true
    return false


static func get_default_font_size(theme: Theme, include_base_themes := true) -> int:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font_size(): return s.theme.default_font_size
    return ThemeDB.fallback_font_size


# TODO: -1 will clear (value smaller 1 will clear)
static func set_default_font_size(theme: Theme, value: int = -1) -> void:
    if theme and not is_built_in_theme(theme):
        if value < 1: value = -1
        theme.default_font_size = value


static func clear_default_font_size(theme: Theme) -> void:
    set_default_font_size(theme, -1)

#endregion

#region Data types

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

static func get_type_list(
    theme: Theme,
    include_variations := false,
    include_base_themes := true,
    sort := true
) -> PackedStringArray:
    var result := PackedStringArray()

    for s in ThemeIterator.new(theme, include_base_themes):
        for type in s.theme.get_type_list():
            if not include_variations and s.theme.get_type_variation_base(type):
                continue
            if type not in result:
                result.append(type)

    if sort: result.sort()
    return result


static func get_type_variation_list(
    theme: Theme,
    base_type: StringName,
    include_base_themes := true,
    sort := true
) -> PackedStringArray:
    var result := PackedStringArray()

    for s in ThemeIterator.new(theme, include_base_themes):
        for variation in s.theme.get_type_variation_list(base_type):
            if variation not in result:
                result.append(variation)

    if sort: result.sort()
    return result


static func has_type(
    theme: Theme,
    theme_type: StringName,
    include_base_themes := false
) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if theme_type in s.theme.get_type_list(): return true
    return false


static func is_built_in_type(
    type: StringName,
    max_api_depth := ClassDB.API_EDITOR_EXTENSION
) -> bool:
    var api_type := ClassDB.APIType.API_NONE
    if ClassDB.class_exists(type):
        api_type = ClassDB.class_get_api_type(type)
    return api_type <= max_api_depth

#endregion

#region Theme items

static func get_theme_item_type_list(
    theme: Theme,
    data_type: Theme.DataType,
    include_variations := false,
    include_base_themes := true,
    sort := true
) -> PackedStringArray:
    var result := PackedStringArray()

    for s in ThemeIterator.new(theme, include_base_themes):
        for type in s.theme.get_theme_item_type_list(data_type):
            if not include_variations and s.theme.get_type_variation_base(type):
                continue
            if type not in result:
                result.append(type)

    if sort: result.sort()
    return result


static func get_theme_item_list(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    include_defaults := true,
    sort := true
) -> PackedStringArray:
    var result := PackedStringArray()

    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        for item in s.theme.get_theme_item_list(data_type, s.theme_type):
            if item not in result:
                result.append(item)

    if sort: result.sort()
    return result


# https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html#manage-and-import-items
#static func is_class_item(
#    theme: Theme,
#    data_type: Theme.DataType,
#    theme_type: StringName,
#    name: StringName
#) -> bool:
#    return false


# https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html#manage-and-import-items   
#static func is_custom_item(
#    theme: Theme,
#    data_type: Theme.DataType,
#    theme_type: StringName,
#    name: StringName
#) -> bool:
#    return false


static func has_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    include_defaults := false
) -> bool:
    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        if s.theme.has_theme_item(data_type, name, s.theme_type):
            return true
    return false


static func get_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    include_defaults := true
) -> Variant:
    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        if s.theme.has_theme_item(data_type, name, s.theme_type):
            return s.theme.get_theme_item(data_type, name, s.theme_type)
    return get_data_type_fallback(data_type)
    

static func set_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName,
    value: Variant
) -> void:
    if not theme: return
    if not is_valid_value_for_data_type(data_type, value):
        value = get_data_type_fallback(data_type)
    theme.set_theme_item(data_type, name, theme_type, value)


static func clear_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName
) -> void:
    if not theme: return
    if theme.has_theme_item(data_type, name, theme_type):
        theme.clear_theme_item(data_type, name, theme_type)
        

static func rename_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    old_name: StringName,
    name: StringName,
    include_defaults := true
) -> void:
    if not theme:
        return
    
    if theme.has_theme_item(data_type, name, theme_type):
        theme.clear_theme_item(data_type, name, theme_type)
    
    if not theme.has_theme_item(data_type, old_name, theme_type):
        var value := get_theme_item(theme, data_type, theme_type, old_name, include_defaults)
        theme.set_theme_item(data_type, name, theme_type, value)
        return
    
    theme.rename_theme_item(data_type, old_name, name, theme_type)

#endregion

# TODO: Copy for all types to match original Theme functionality?
#region Colors

static func get_colors_type_list(
    theme: Theme,
    include_variations := false, include_defaults := true, sort := true
) -> PackedStringArray:
    return get_theme_item_type_list(
        theme, Theme.DATA_TYPE_COLOR,
        include_variations, include_defaults, sort
    )

static func get_color_list(
    theme: Theme, theme_type: StringName,
    include_defaults := true, sort := true
) -> PackedStringArray:
    return get_theme_item_list(
        theme, Theme.DATA_TYPE_COLOR, theme_type,
        include_defaults, sort
    )


static func has_color(
    theme: Theme, theme_type: StringName, name: StringName,
    include_defaults := false
) -> bool:
    return has_theme_item(
        theme, Theme.DATA_TYPE_COLOR, theme_type, name,
        include_defaults
    )


static func get_color(
    theme: Theme, theme_type: StringName, name: StringName,
    include_defaults := true
) -> Color:
    return get_theme_item(
        theme, Theme.DATA_TYPE_COLOR, theme_type, name,
        include_defaults
    ) as Color
    

static func set_color(
    theme: Theme, theme_type: StringName, name: StringName, value: Color
) -> void:
    if theme:
        theme.set_color(name, theme_type, value)


static func clear_color(
    theme: Theme, theme_type: StringName, name: StringName
) -> void:
    if theme and theme.has_color(name, theme_type):
        theme.clear_color(name, theme_type)
        

static func rename_color(
    theme: Theme,
    theme_type: StringName, old_name: StringName, name: StringName,
    include_defaults := true
) -> void:
    rename_theme_item(
        theme, Theme.DATA_TYPE_COLOR,
        theme_type, old_name, name,
        include_defaults
    )

#endregion

#region Fonts

static func get_pairing_font_size_name(font_name: StringName) -> StringName:
    return font_name + "_size"


static func has_pairing_font_size(
    theme: Theme,
    theme_type: StringName,
    font_name: StringName,
    include_defaults := false
) -> bool:
    var font_size_name := get_pairing_font_size_name(font_name)
    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        if font_size_name in s.theme.get_font_size_list(s.theme_type):
            return true
    return false


static func get_pairing_font_size(
    theme: Theme,
    theme_type: StringName,
    font_name: StringName,
    include_defaults := true
) -> int:
    var font_size_name := get_pairing_font_size_name(font_name)
    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        if font_size_name in s.theme.get_font_size_list(s.theme_type):
            return s.theme.get_font_size(font_size_name, s.theme_type)
    return get_default_font_size(theme, include_defaults)

#endregion

#region Font Sizes

static func get_pairing_font_name(font_size_name: StringName) -> StringName:
    return font_size_name.trim_suffix("_size")


static func has_pairing_font(
    theme: Theme,
    theme_type: StringName,
    font_size_name: StringName,
    include_defaults := false
) -> bool:
    var font_name := get_pairing_font_name(font_size_name)
    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        if font_name in s.theme.get_font_list(s.theme_type):
            return true
    return false


static func get_pairing_font(
    theme: Theme,
    theme_type: StringName,
    font_size_name: StringName,
    include_defaults := true
) -> Font:
    var font_name := get_pairing_font_name(font_size_name)
    for s in ThemeTypeIterator.new(theme, theme_type, include_defaults, include_defaults):
        if font_name in s.theme.get_font_list(s.theme_type):
            return s.theme.get_font(font_name, s.theme_type)
    return get_default_font(theme, include_defaults)

#endregion

#region Property paths

static func _get_data_type_property_path(data_type: Theme.DataType) -> StringName:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return &"colors"
        Theme.DATA_TYPE_CONSTANT:  return &"constants"
        Theme.DATA_TYPE_FONT:      return &"font"
        Theme.DATA_TYPE_FONT_SIZE: return &"font_sizes"
        Theme.DATA_TYPE_ICON:      return &"icons"
        Theme.DATA_TYPE_STYLEBOX:  return &"styles"
        _:                         return &""


static func _get_data_type_from_property_path(property_path: StringName) -> Theme.DataType:
    match property_path:
        &"colors":     return Theme.DATA_TYPE_COLOR
        &"constants":  return Theme.DATA_TYPE_CONSTANT
        &"font":       return Theme.DATA_TYPE_FONT
        &"font_sizes": return Theme.DATA_TYPE_FONT_SIZE
        &"icons":      return Theme.DATA_TYPE_ICON
        &"styles":     return Theme.DATA_TYPE_STYLEBOX
        _:             return -1


static func get_theme_item_property_path(
    data_type: Theme.DataType,
    theme_type: StringName,
    name: StringName
) -> StringName:
    return "%s/%s/%s" % [
        theme_type,
        _get_data_type_property_path(data_type),
        name
    ]


static func get_theme_item_type_from_property_path(
    property_path: StringName
) -> StringName:
    return property_path.get_slice("/", 0)


static func get_theme_item_data_type_from_property_path(
    property_path: StringName
) -> Theme.DataType:
    var data_type := property_path.get_slice("/", 1)
    return _get_data_type_from_property_path(data_type)


static func get_theme_item_name_from_property_path(
    property_path: StringName
) -> StringName:
    return property_path.get_slice("/", 2)
    

# TODO: name.is_valid_ascii_identifier()
static func get_theme_item_override_property_path(
    data_type: Theme.DataType,
    name: StringName
) -> StringName:
    return "%s/%s" % [
        "theme_override_%s" % _get_data_type_property_path(data_type),
        name
    ]


static func get_theme_item_data_type_from_override_property_path(
    property_path: StringName
) -> Theme.DataType:
    return _get_data_type_from_property_path(
        property_path.get_slice("/", 0).trim_prefix("theme_override_")
    )


static func get_theme_item_name_from_override_property_path(
    property_path: StringName
) -> StringName:
    return property_path.get_slice("/", 1)

#endregion

#region Themes (Editor utilities)

static func get_theme_name(theme: Theme) -> String:
    if not theme:
        return &"Missing Resource"
    
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return &"Editor"
            
    var default_theme := ThemeDB.get_default_theme()
    if theme == default_theme:
        return &"Default"
    
    var project_theme := ThemeDB.get_project_theme()
    if project_theme and not theme == project_theme:
        return &"Project"

    if theme.resource_path:
        return theme.resource_path.get_file()
    
    return &"Theme"


static func get_theme_icon(theme: Theme) -> Texture2D:
    if not Engine.is_editor_hint():
        return ThemeDB.fallback_icon
    
    var editor_theme := EditorInterface.get_editor_theme()
    if not theme:
        return editor_theme.get_icon(&"MissingResource", &"EditorIcons")
    
    if is_built_in_theme(theme):
        return editor_theme.get_icon(&"GuiVisibilityXray", &"EditorIcons")
    
    return editor_theme.get_icon(&"Theme", &"EditorIcons")

#endregion

#region Data types (Editor utilities)

static func get_data_type_name(data_type: Theme.DataType) -> StringName:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return &"Colors"
        Theme.DATA_TYPE_CONSTANT:  return &"Constants"
        Theme.DATA_TYPE_FONT:      return &"Fonts"
        Theme.DATA_TYPE_FONT_SIZE: return &"Font sizes"
        Theme.DATA_TYPE_ICON:      return &"Icons"
        Theme.DATA_TYPE_STYLEBOX:  return &"StyleBoxes"
        _:                         return StringName()


static func get_data_type_tags(data_type: Theme.DataType) -> Array[StringName]:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return [&"colors"]
        Theme.DATA_TYPE_CONSTANT:  return [&"constants"]
        Theme.DATA_TYPE_FONT:      return [&"fonts"]
        Theme.DATA_TYPE_FONT_SIZE: return [&"fonts", &"sizes"]
        Theme.DATA_TYPE_ICON:      return [&"icons"]
        Theme.DATA_TYPE_STYLEBOX:  return [&"styles", &"boxes"]
        _:                         return []


static func get_data_type_icon(data_type: Theme.DataType) -> Texture2D:
    if not Engine.is_editor_hint():
        return ThemeDB.fallback_icon
    
    var editor_theme := EditorInterface.get_editor_theme()
    match data_type:
        Theme.DATA_TYPE_COLOR:     return editor_theme.get_icon(&"Color", &"EditorIcons")
        Theme.DATA_TYPE_CONSTANT:  return editor_theme.get_icon(&"MemberConstant", &"EditorIcons")
        Theme.DATA_TYPE_FONT:      return editor_theme.get_icon(&"FontItem", &"EditorIcons")
        Theme.DATA_TYPE_FONT_SIZE: return editor_theme.get_icon(&"FontSize", &"EditorIcons")
        Theme.DATA_TYPE_ICON:      return editor_theme.get_icon(&"ImageTexture", &"EditorIcons")
        Theme.DATA_TYPE_STYLEBOX:  return editor_theme.get_icon(&"StyleBoxFlat", &"EditorIcons")
        _:                         return ThemeDB.fallback_icon

#endregion

#region Theme types (Editor utilities)

static func get_theme_type_icon(theme_type: StringName) -> Texture2D:
    if not Engine.is_editor_hint():
        return ThemeDB.fallback_icon
    
    var editor_theme := EditorInterface.get_editor_theme()
    if editor_theme.has_icon(theme_type, &"EditorIcons"):
        return editor_theme.get_icon(theme_type, &"EditorIcons")
    return editor_theme.get_icon(&"NodeDisabled", &"EditorIcons")

#endregion

#region Constants (Editor utilities)

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
    
    
static func get_constant_type_suffix(type: ConstantType) -> StringName:
    match type:
        ConstantType.PIXEL:  return &"px"
        ConstantType.FACTOR: return &"x"
        _:                   return &""

#endregion
