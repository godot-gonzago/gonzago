@tool
@static_unload
extends RefCounted
## Editor utility for GUI theme.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Themes

static func get_theme_name(theme: Theme) -> String:
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
    
    return StringName()


static func get_theme_icon(theme: Theme) -> Texture2D:
    if not Engine.is_editor_hint():
        return ThemeDB.fallback_icon
    
    var editor_theme := EditorInterface.get_editor_theme()
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
