@tool
@static_unload
extends RefCounted
## Editor utility for GUI theme.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Themes

static func get_theme_name(theme: Theme) -> String:
    if not theme:
        return &"Missing Resource"
    
    if Engine.is_editor_hint():
        if theme == EditorInterface.get_editor_theme():
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
    
    var is_readonly := theme == editor_theme
    
    if not is_readonly:
        var default_theme := ThemeDB.get_default_theme()
        is_readonly = theme == default_theme
        
    if is_readonly:
        return editor_theme.get_icon(&"GuiVisibilityXray", &"EditorIcons")
    return editor_theme.get_icon(&"Theme", &"EditorIcons")

#endregion

#region Data types

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

#region Theme types

static func get_theme_type_icon(theme_type: StringName) -> Texture2D:
    if not Engine.is_editor_hint():
        return ThemeDB.fallback_icon
    
    var editor_theme := EditorInterface.get_editor_theme()
    if editor_theme.has_icon(theme_type, &"EditorIcons"):
        return editor_theme.get_icon(theme_type, &"EditorIcons")
    return editor_theme.get_icon(&"NodeDisabled", &"EditorIcons")

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
    
    
static func get_constant_type_suffix(type: ConstantType) -> StringName:
    match type:
        ConstantType.PIXEL:  return &"px"
        ConstantType.FACTOR: return &"x"
        _:                   return StringName("")

#endregion
