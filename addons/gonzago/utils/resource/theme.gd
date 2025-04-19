@tool
@static_unload
extends RefCounted
## Utility for [Theme] resources.
##
## Provides utility functions for [Theme] resources.
## Most functionality extends the default functions already provided by [Theme]
## but generalizes their use.

const _Self := preload("./theme.gd")

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

        state._theme = _Self.get_base_theme(state.theme)
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
class ThemeTypeIterator extends RefCounted:
    class State extends RefCounted:
        var _theme_type: StringName
        var _is_base_type: bool = false

        var theme_type: StringName:
            get: return _theme_type
        var is_base_type: bool:
            get: return _is_base_type

        func _init(theme_type: StringName) -> void:
            _theme_type = theme_type

    var _theme: Theme
    var _initial_theme_type: StringName
    var _include_base_types: bool

    func _init(
        theme: Theme, theme_type: StringName,
        include_base_types := true
    ) -> void:
        _theme = theme
        _initial_theme_type = theme_type
        _include_base_types = include_base_types

    func _iter_init(iter: Array) -> bool:
        if not _theme or not _initial_theme_type:
            iter[0] = null
            return false
        iter[0] = State.new(_initial_theme_type)
        return true

    func _iter_next(iter: Array) -> bool:
        var state := iter[0] as State
        if not state:
            iter[0] = null
            return false

        if _include_base_types:
            state._theme_type = _theme.get_type_variation_base(state.theme_type)
            if state.theme_type:
                state._is_base_type = true
                return true

        iter[0] = null
        return false

    func _iter_get(current: Variant) -> State:
        return current as State


## Complex hierarchical iterator for types in [Theme] resources.
##
## This iterator allows for iteration over types in a [Theme] and optionally its base types.
## If [param include_base_types] is set to [code]true[/code] the iterator tries
## to find the base types if the given [param theme_type] is a variation.
## If [param include_base_themes] is set to [code]true[/code] the iterator tries
## to find the base themes next. For regular themes this is first the project theme
## if available and then the default theme.
class DefaultsIterator extends RefCounted:
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
    var _initial_theme_type: StringName
    var _include_defaults: bool

    func _init(
        theme: Theme, theme_type: StringName,
        include_defaults := true
    ) -> void:
        _initial_theme = theme
        _initial_theme_type = theme_type
        _include_defaults = include_defaults

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

        if _include_defaults:
            state._theme_type = state.theme.get_type_variation_base(state.theme_type)
            if state.theme_type:
                state._is_base_type = true
                return true

            state._theme = _Self.get_base_theme(state.theme)
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

## The type of a [Theme] resource.
enum ThemeType {
    ## Unknown or invalid theme type.
    NONE = -1,
    ## [Theme] resource currently in memory without a
    ## [member Resource.resource_path].
    MEMORY = 0,
    ## Persistent [Theme] resource with a
    ## [member Resource.resource_path].
    RESOURCE = 1,
    ## The project [Theme] resource referenced in
    ## [method ThemeDB.get_project_theme].
    PROJECT = 2,
    ## Internal default [Theme] resource referenced in
    ## [method ThemeDB.get_default_theme].
    DEFAULT = 3,
    ## Internal editor [Theme] resource referenced in
    ## [method EditorInterface.get_editor_theme].
    EDITOR = 4
}


## Returns the type of the given [param theme].
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


## Returns [code]true[/code] if the given [param theme] has a base theme.[br][br]
## The theme referenced in [method ThemeDB.get_default_theme]
## is considered the general base theme for all themes.[br][br]
## An invalid [param theme] will return [code]false[/code].
static func has_base_theme(theme: Theme) -> bool:
    if not theme:
        return false
    if theme.resource_path:
        return true
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return true
    return theme != ThemeDB.get_default_theme()


## Returns the base theme for the given [param theme].[br][br]
## The returned [Theme] will either be the default theme referenced in
## [method ThemeDB.get_default_theme] or the project theme referenced in
## [method ThemeDB.get_project_theme].[br][br]
## An invalid [param theme] or a root base theme will return [code]null[/code].
static func get_base_theme(theme: Theme) -> Theme:
    if not theme:
        return null

    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return ThemeDB.get_default_theme()

    var default_theme := ThemeDB.get_default_theme()
    if theme == default_theme:
        return null

    var project_theme := ThemeDB.get_project_theme()
    if project_theme and not theme == project_theme:
        return project_theme

    return default_theme


## Returns [code]true[/code] if the given [param theme] is a built-in theme.[br][br]
## Built-in themes are either the default theme referenced in
## [method ThemeDB.get_default_theme] or the editor theme referenced in
## [method EditorInterface.get_editor_theme] as they are not editable.[br][br]
## An invalid [param theme] will return [code]false[/code].
static func is_built_in_theme(theme: Theme) -> bool:
    if not theme:
        return false
    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return true
    if theme == ThemeDB.get_default_theme():
        return true
    return false


## Returns [code]true[/code] if [member Theme.default_base_scale] has a
## valid value for [param theme].[br][br]
## An invalid [param theme] will return [code]false[/code].
## If [param include_base_themes] is [code]true[/code] will also check
## base themes of [param theme].[br][br]
## The value must be greater than [code]0.0[/code] to be considered valid.[br][br]
## [b]Note:[/b] This method wraps [method Theme.has_default_base_scale].
static func has_default_base_scale(theme: Theme, include_base_themes := false) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_base_scale(): return true
    return false


## Returns [member Theme.default_base_scale] if it has a valid value.[br][br]
## An invalid [param theme] or if no valid base scale is present
## will return [member ThemeDB.fallback_base_scale].
## If [param include_base_themes] is [code]true[/code] will also check
## base themes of [param theme].[br][br]
## The value must be greater than [code]0.0[/code] to be considered valid.[br][br]
## [b]Note:[/b] This method wraps [member Theme.default_base_scale].
static func get_default_base_scale(theme: Theme, include_base_themes := true) -> float:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_base_scale(): return s.theme.default_base_scale
    return ThemeDB.fallback_base_scale


## Sets the default base scale factor of the [param theme] resource.
## A [param value] smaller or equal to [code]0.0[/code] is invalid and will remove the base scale.[br][br]
## [b]Note:[/b] This method wraps [member Theme.default_base_scale].
static func set_default_base_scale(theme: Theme, value: float = 0.0) -> void:
    if theme and not is_built_in_theme(theme):
        if value < 0.0: value = 0.0
        theme.default_base_scale = maxf(0.0, value)


## Clears the default base scale factor of the [param theme] resource.[br][br]
## [b]Note:[/b] This method will set [member Theme.default_base_scale] to [code]0.0[/code].
static func clear_default_base_scale(theme: Theme) -> void:
    set_default_base_scale(theme, 0.0)


## Returns [code]true[/code] if [member Theme.default_font] has a
## valid value for [param theme].[br][br]
## An invalid [param theme] will return [code]false[/code].
## If [param include_base_themes] is [code]true[/code] will also check
## base themes of [param theme].[br][br]
## The value must be a valid [Font] resource to be considered valid.[br][br]
## [b]Note:[/b] This method wraps [method Theme.has_default_font].
static func has_default_font(theme: Theme, include_base_themes := false) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font(): return true
    return false


## Returns [member Theme.default_font] if it has a valid value.[br][br]
## An invalid [param theme] or if no valid default font is present
## will return [member ThemeDB.fallback_font].
## If [param include_base_themes] is [code]true[/code] will also check
## base themes of [param theme].[br][br]
## The value must be a valid [Font] resource to be considered valid.[br][br]
## [b]Note:[/b] This method wraps [member Theme.default_font].
static func get_default_font(theme: Theme, include_base_themes := true) -> Font:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font(): return s.theme.default_font
    return ThemeDB.fallback_font


## Sets the default font of the [param theme] resource.
## A [param value] of an invalid [Font] resource will remove the default font.[br][br]
## [b]Note:[/b] This method wraps [member Theme.default_font].
static func set_default_font(theme: Theme, value: Font = null) -> void:
    if theme and not is_built_in_theme(theme):
        theme.default_font = value


## Clears the default font of the [param theme] resource.[br][br]
## [b]Note:[/b] This method will set [member Theme.default_font] to [code]null[/code].
static func clear_default_font(theme: Theme) -> void:
    set_default_font(theme, null)


## Returns [code]true[/code] if [member Theme.default_font_size] has a
## valid value for [param theme].[br][br]
## An invalid [param theme] will return [code]false[/code].
## If [param include_base_themes] is [code]true[/code] will also check
## base themes of [param theme].[br][br]
## The value must be greater than [code]0[/code] to be considered valid.[br][br]
## [b]Note:[/b] This method wraps [method Theme.has_default_font_size].
static func has_default_font_size(theme: Theme, include_base_themes := false) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font_size(): return true
    return false


## Returns [member Theme.default_font_size] if it has a valid value.[br][br]
## An invalid [param theme] or if no valid default font size is present
## will return [member ThemeDB.fallback_font_size].
## If [param include_base_themes] is [code]true[/code] will also check
## base themes of [param theme].[br][br]
## The value must be greater than [code]0[/code] to be considered valid.[br][br]
## [b]Note:[/b] This method wraps [member Theme.default_font_size].
static func get_default_font_size(theme: Theme, include_base_themes := true) -> int:
    for s in ThemeIterator.new(theme, include_base_themes):
        if s.theme.has_default_font_size(): return s.theme.default_font_size
    return ThemeDB.fallback_font_size


## Sets the default font size of the [param theme] resource.
## A [param value] smaller than [code]1[/code] is invalid and will remove the default font size.[br][br]
## [b]Note:[/b] This method wraps [member Theme.default_font_size].
static func set_default_font_size(theme: Theme, value: int = 0) -> void:
    if theme and not is_built_in_theme(theme):
        if value < 1: value = 0
        theme.default_font_size = value


## Clears the default font size of the [param theme] resource.[br][br]
## [b]Note:[/b] This method will set [member Theme.default_font_size] to [code]0[/code].
static func clear_default_font_size(theme: Theme) -> void:
    set_default_font_size(theme, 0)

#endregion

#region Themes (Editor utilities)

## Returns an appropriate display name for the [param theme].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
static func get_theme_name(theme: Theme) -> StringName:
    if not theme:
        return &"Missing Resource"

    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return &"Editor"

    if theme == ThemeDB.get_default_theme():
        return &"Default"

    var project_theme := ThemeDB.get_project_theme()
    if project_theme and theme == project_theme:
        return &"Project"

    if theme.resource_path:
        return theme.resource_path.get_file()

    return &"New Theme"


## Returns an appropriate tooltip for the [param theme].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
static func get_theme_tooltip(theme: Theme) -> StringName:
    if not theme:
        return &"Missing Resource"

    if Engine.is_editor_hint() and theme == EditorInterface.get_editor_theme():
        return &"Editor Theme"

    if theme == ThemeDB.get_default_theme():
        return &"Default Theme"

    var project_theme := ThemeDB.get_project_theme()
    if project_theme and theme == project_theme:
        return &"Project Theme defined in ProjectSettings"

    if theme.resource_path:
        return theme.resource_path

    return &"New Theme"


## Returns an appropriate icon for the [param theme].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
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

#region Data types

## Returns an appropriate fallback value for [param data_type].[br][br]
## Returns [constant Color.BLACK] for [constant Theme.DATA_TYPE_COLOR],
## [code]0[/code] for [constant Theme.DATA_TYPE_CONSTANT],
## [member ThemeDB.fallback_font] for [constant Theme.DATA_TYPE_FONT],
## [member ThemeDB.fallback_font_size] for [constant Theme.DATA_TYPE_FONT_SIZE],
## [member ThemeDB.fallback_icon] for [constant Theme.DATA_TYPE_ICON],
## [member ThemeDB.fallback_stylebox] for [constant Theme.DATA_TYPE_STYLEBOX],
## otherwise returns [code]null[/code].
static func get_data_type_fallback(data_type: Theme.DataType) -> Variant:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return Color.BLACK
        Theme.DATA_TYPE_CONSTANT:  return 0
        Theme.DATA_TYPE_FONT:      return ThemeDB.fallback_font
        Theme.DATA_TYPE_FONT_SIZE: return ThemeDB.fallback_font_size
        Theme.DATA_TYPE_ICON:      return ThemeDB.fallback_icon
        Theme.DATA_TYPE_STYLEBOX:  return ThemeDB.fallback_stylebox
        _:                         return null


## Returns [code]true[/code] if [param value] is a valid value for [param data_type].
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

#region Data types (Property paths)

# Utility function for gettings property paths.
# Used in [method get_theme_item_property_path] and
# [method get_theme_item_override_property_path].
static func _get_data_type_property_path(data_type: Theme.DataType) -> StringName:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return &"colors"
        Theme.DATA_TYPE_CONSTANT:  return &"constants"
        Theme.DATA_TYPE_FONT:      return &"font"
        Theme.DATA_TYPE_FONT_SIZE: return &"font_sizes"
        Theme.DATA_TYPE_ICON:      return &"icons"
        Theme.DATA_TYPE_STYLEBOX:  return &"styles"
        _:                         return &""


# Utility function for gettings data types from property paths.
# Used in [method get_theme_item_data_type_from_property_path] and
# [method get_theme_item_data_type_from_override_property_path].
static func _get_data_type_from_property_path(property_path: StringName) -> Theme.DataType:
    match property_path:
        &"colors":     return Theme.DATA_TYPE_COLOR
        &"constants":  return Theme.DATA_TYPE_CONSTANT
        &"font":       return Theme.DATA_TYPE_FONT
        &"font_sizes": return Theme.DATA_TYPE_FONT_SIZE
        &"icons":      return Theme.DATA_TYPE_ICON
        &"styles":     return Theme.DATA_TYPE_STYLEBOX
        _:             return -1

#endregion

#region Data types (Editor utilities)

## Returns an appropriate display name for the [enum Theme.DataType].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
static func get_data_type_name(data_type: Theme.DataType) -> StringName:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return &"Colors"
        Theme.DATA_TYPE_CONSTANT:  return &"Constants"
        Theme.DATA_TYPE_FONT:      return &"Fonts"
        Theme.DATA_TYPE_FONT_SIZE: return &"Font sizes"
        Theme.DATA_TYPE_ICON:      return &"Icons"
        Theme.DATA_TYPE_STYLEBOX:  return &"StyleBoxes"
        _:                         return StringName()


## Returns an appropriate list of tags for the [enum Theme.DataType].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
static func get_data_type_tags(data_type: Theme.DataType) -> Array[StringName]:
    match data_type:
        Theme.DATA_TYPE_COLOR:     return [&"colors"]
        Theme.DATA_TYPE_CONSTANT:  return [&"constants"]
        Theme.DATA_TYPE_FONT:      return [&"fonts"]
        Theme.DATA_TYPE_FONT_SIZE: return [&"fonts", &"sizes"]
        Theme.DATA_TYPE_ICON:      return [&"icons"]
        Theme.DATA_TYPE_STYLEBOX:  return [&"styles", &"boxes"]
        _:                         return []


## Returns an appropriate icon for the [enum Theme.DataType].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
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

## Returns a list of all unique theme type names in [param theme].[br][br]
## If [param include_variations] is [code]true[/code] variations are included in the resulting list,
## otherwise only theme types that don't have a variation base are included.
## If [param include_base_themes] is [code]true[/code] the result also includes theme types from
## base themes of [param theme], otherwise only data in [param theme] is checked and included.
## If [param sort] is [code]true[/code] the resulting list will be sorted alphabetically.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_type_list].
static func get_type_list(
    theme: Theme,
    include_variations := false,
    include_base_themes := true,
    sort := true
) -> PackedStringArray:
    var result := PackedStringArray()

    for s in ThemeIterator.new(theme, include_base_themes):
        for type in s.theme.get_type_list():
            if not include_variations:
                if get_type_variation_base(s.theme, type, include_base_themes):
                    continue
            if type not in result:
                result.append(type)

    if sort: result.sort()
    return result


## Returns a list of all type variations for the given [param base_type] in [param theme].[br][br]
## If [param include_base_themes] is [code]true[/code] the result also includes theme types from
## base themes of [param theme], otherwise only data in [param theme] is checked and included.
## If [param sort] is [code]true[/code] the resulting list will be sorted alphabetically.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_type_variation_list].
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


## Returns the name of the base theme type if [param theme_type] is a
## valid variation type in [param theme]. Returns an empty string otherwise.[br][br]
## If [param include_base_themes] is [code]true[/code] the result also checks variations in
## base themes of [param theme], otherwise only data in [param theme] is checked and included.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_type_variation_base].
static func get_type_variation_base(
    theme: Theme,
    theme_type: StringName,
    include_base_themes := true
) -> StringName:
    for s in ThemeIterator.new(theme, include_base_themes):
        var variation_base := s.theme.get_type_variation_base(theme_type)
        if variation_base:
            return variation_base
    return &""


## Returns the [Theme] the given [param theme_type] is found in first.[br][br]
## [b]Note:[/b] This method will check base themes, if [param theme] does not contain [param type].
static func get_base_theme_for_type(
    theme: Theme,
    theme_type: StringName
) -> Theme:
    for s in ThemeIterator.new(theme, true):
        if theme_type in s.theme.get_type_list():
            return s.theme
    return null


## Returns [code]true[/code] if [param theme] contains [param theme_type],
## otherwise returns [code]false[/code].[br][br]
## If [param include_base_themes] is [code]true[/code] the result also checks
## base themes of [param theme], otherwise only data in [param theme] is checked and included.
static func has_type(
    theme: Theme,
    theme_type: StringName,
    include_base_themes := false
) -> bool:
    for s in ThemeIterator.new(theme, include_base_themes):
        if theme_type in s.theme.get_type_list(): return true
    return false


## Returns [code]true[/code] if [param type] is a built-in type.[br][br]
## This uses [method ClassDB.class_get_api_type] to look for types.
## The api type for [param type] needs to be smaller than or equal to
## [param max_api_depth] to count as built-in (can be set to a [enum ClassDB.APIType]).
static func is_built_in_type(
    type: StringName,
    max_api_depth := ClassDB.API_EDITOR_EXTENSION
) -> bool:
    var api_type := ClassDB.APIType.API_NONE
    if ClassDB.class_exists(type):
        api_type = ClassDB.class_get_api_type(type)
    return api_type <= max_api_depth

#endregion

#region Theme types (Editor utilities)

## Returns an appropriate icon for the [param theme_type].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
static func get_theme_type_icon(theme_type: StringName) -> Texture2D:
    if not Engine.is_editor_hint():
        return ThemeDB.fallback_icon

    var editor_theme := EditorInterface.get_editor_theme()
    if editor_theme.has_icon(theme_type, &"EditorIcons"):
        return editor_theme.get_icon(theme_type, &"EditorIcons")
    return editor_theme.get_icon(&"NodeDisabled", &"EditorIcons")

#endregion

#region Theme items

## Returns a list of all unique theme type names for [param data_type] properties in [param theme].[br][br]
## If [param include_variations] is [code]true[/code] variations are included in the resulting list,
## otherwise only theme types that don't have a variation base are included.
## If [param include_base_themes] is [code]true[/code] the result also includes theme types from
## base themes of [param theme], otherwise only data in [param theme] is checked and included.
## If [param sort] is [code]true[/code] the resulting list will be sorted alphabetically.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_theme_item_type_list].
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
            if not include_variations:
                if get_type_variation_base(s.theme, type, include_base_themes):
                    continue
            if type not in result:
                result.append(type)

    if sort: result.sort()
    return result


## Returns a list of names for properties of [param data_type] defined with [param theme_type] in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the results.
## If [param sort] is [code]true[/code] the resulting list will be sorted alphabetically.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_theme_item_list].
static func get_theme_item_list(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    include_defaults := true,
    sort := true
) -> PackedStringArray:
    var result := PackedStringArray()

    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        for item in s.theme.get_theme_item_list(data_type, s.theme_type):
            if item not in result:
                result.append(item)

    if sort: result.sort()
    return result


## Returns the [Theme] the given theme item is found in first.[br][br]
## [b]Note:[/b] This method will check base variations for [param theme_type] if the theme item cannot be found.
## [b]Note:[/b] This method will check base themes, if [param theme] does not contain the theme item.
static func get_base_theme_for_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName
) -> Theme:
    for s in DefaultsIterator.new(theme, theme_type, true):
        if s.theme.has_theme_item(data_type, name, s.theme_type):
            return s.theme
    return null


## Returns the theme type the given theme item is found in first.[br][br]
## [b]Note:[/b] This method will check base variations for [param theme_type] if the theme item cannot be found.
## [b]Note:[/b] This method will check base themes, if [param theme] does not contain the theme item.
static func get_base_type_for_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName
) -> StringName:
    for s in DefaultsIterator.new(theme, theme_type, true):
        if s.theme.has_theme_item(data_type, name, s.theme_type):
            return s.theme_type
    return &""


## Returns [code]true[/code] if the given theme item is a class item.[br][br]
## TODO: Theme items are class items if they are present in a built-in theme?
## @experimental
static func is_class_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName
) -> bool:
    # TODO: Implement
    # https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html#manage-and-import-items
    return false


## Returns [code]true[/code] if the given theme item is a custom item.[br][br]
## TODO: Theme items are custom items if they are not present in a built-in theme?
## @experimental
static func is_custom_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName
) -> bool:
    # TODO: Implement
    # https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html#manage-and-import-items
    return false


## Returns [code]true[/code] if the theme property of [param data_type] defined
## by [param name] and [param theme_type] exists in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.[br][br]
## [b]Note:[/b] This method wraps [method Theme.has_theme_item].
static func has_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName,
    include_defaults := false
) -> bool:
    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        if s.theme.has_theme_item(data_type, name, s.theme_type):
            return true
    return false


## Returns the theme property of [param data_type] defined by [param name] and
## [param theme_type], if it exists in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.[br][br]
## Returns the engine fallback value if the property doesn't exist.
## Use [method has_theme_item] to check for existence.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_theme_item].
static func get_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName,
    include_defaults := true
) -> Variant:
    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        if s.theme.has_theme_item(data_type, name, s.theme_type):
            return s.theme.get_theme_item(data_type, name, s.theme_type)
    return get_data_type_fallback(data_type)


## Creates or changes the [param value] of the [param theme] property
## of [param data_type] defined by [param name] and [param theme_type].
## If [param value] is not valid for [param data_type] an appropriate
## fallback value will be set.[br][br]
## [b]Note:[/b] This method wraps [method Theme.set_theme_item].
static func set_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName,
    value: Variant
) -> void:
    if not theme: return
    if not is_valid_value_for_data_type(data_type, value):
        value = get_data_type_fallback(data_type)
    theme.set_theme_item(data_type, name, theme_type, value)


## Removes the theme property of [param data_type] defined by [param name] and [param theme_type],
## if it exists in [param theme].[br][br]
## [b]Note:[/b] This method wraps [method Theme.clear_theme_item] but does not fail
## if it doesn't exist. Use [method has_theme_item] to check for existence.
static func clear_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName
) -> void:
    if not theme: return
    if theme.has_theme_item(data_type, name, theme_type):
        theme.clear_theme_item(data_type, name, theme_type)


## Renames the theme property of [param data_type] defined by [param old_name]
## and [param theme_type] to [param name], if it exists in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.[br][br]
## [b]Note:[/b] This method wraps [method Theme.rename_theme_item] but does not fail
## if [param old_name] doesn't exist, or if a property with [param name] already exists.
## Use [method has_theme_item] to check for existence and [method clear_theme_item] to remove the existing property.
static func rename_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    old_name: StringName,
    name: StringName,
    theme_type: StringName,
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

#region Theme items (Property paths)

## Returns the property path for a theme item stored in [Theme].[br][br]
## The format is [code]"theme_type/data_type_name/name"[/code],
## eg. [code]"Button/colors/font_color"[/code].
static func get_theme_item_property_path(
    data_type: Theme.DataType,
    name: StringName,
    theme_type: StringName
) -> StringName:
    return "%s/%s/%s" % [
        theme_type,
        _get_data_type_property_path(data_type),
        name
    ]


## Returns the theme type from the [param property_path]
## used for storing a theme item in a [Theme].[br][br]
## The format is [code]"theme_type/data_type_name/name"[/code],
## eg. [code]"Button/colors/font_color"[/code].
static func get_theme_item_type_from_property_path(
    property_path: StringName
) -> StringName:
    return property_path.get_slice("/", 0)


## Returns the [enum Theme.DataType] from the [param property_path]
## used for storing a theme item in a [Theme].[br][br]
## The format is [code]"theme_type/data_type_name/name"[/code],
## eg. [code]"Button/colors/font_color"[/code].
static func get_theme_item_data_type_from_property_path(
    property_path: StringName
) -> Theme.DataType:
    var data_type := property_path.get_slice("/", 1)
    return _get_data_type_from_property_path(data_type)


## Returns the theme item name from the [param property_path]
## used for storing a theme item in a [Theme].[br][br]
## The format is [code]"theme_type/data_type_name/name"[/code],
## eg. [code]"Button/colors/font_color"[/code].
static func get_theme_item_name_from_property_path(
    property_path: StringName
) -> StringName:
    return property_path.get_slice("/", 2)


## Returns the property path for a theme override stored in a [Control].[br][br]
## The format is [code]"theme_override_data_type_name/name"[/code],
## eg. [code]"theme_override_colors/font_color"[/code].
static func get_theme_item_override_property_path(
    data_type: Theme.DataType,
    name: StringName
) -> StringName:
    # TODO: name.is_valid_ascii_identifier()
    return "%s/%s" % [
        "theme_override_%s" % _get_data_type_property_path(data_type),
        name
    ]


## Returns the [enum Theme.DataType] from the [param property_path]
## used for storing a theme override in a [Control].[br][br]
## The format is [code]"theme_override_data_type_name/name"[/code],
## eg. [code]"theme_override_colors/font_color"[/code].
static func get_theme_item_data_type_from_override_property_path(
    property_path: StringName
) -> Theme.DataType:
    return _get_data_type_from_property_path(
        property_path.get_slice("/", 0).trim_prefix("theme_override_")
    )


## Returns the theme item name from the [param property_path]
## used for storing a theme override in a [Control].[br][br]
## The format is [code]"theme_override_data_type_name/name"[/code],
## eg. [code]"theme_override_colors/font_color"[/code].
static func get_theme_item_name_from_override_property_path(
    property_path: StringName
) -> StringName:
    return property_path.get_slice("/", 1)

#endregion

# TODO: Copy for all types to match original Theme functionality?
#region Colors

## Returns a list of all unique theme type names for [Color] properties in [param theme].[br][br]
## If [param include_variations] is [code]true[/code] variations are included in the resulting list,
## otherwise only theme types that don't have a variation base are included.
## If [param include_base_themes] is [code]true[/code] the result also includes theme types from
## base themes of [param theme], otherwise only data in [param theme] is checked and included.
## If [param sort] is [code]true[/code] the resulting list will be sorted alphabetically.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_colors_type_list].
static func get_colors_type_list(
    theme: Theme,
    include_variations := false, include_base_themes := true, sort := true
) -> PackedStringArray:
    return get_theme_item_type_list(
        theme, Theme.DATA_TYPE_COLOR,
        include_variations, include_base_themes, sort
    )


## Returns a list of names for [Color] properties defined with [param theme_type] in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the results.
## If [param sort] is [code]true[/code] the resulting list will be sorted alphabetically.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_color_list].
static func get_color_list(
    theme: Theme, theme_type: StringName,
    include_defaults := true, sort := true
) -> PackedStringArray:
    return get_theme_item_list(
        theme, Theme.DATA_TYPE_COLOR, theme_type,
        include_defaults, sort
    )


## Returns [code]true[/code] if the [Color] property defined
## by [param name] and [param theme_type] exists in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.[br][br]
## [b]Note:[/b] This method wraps [method Theme.has_color].
static func has_color(
    theme: Theme, name: StringName, theme_type: StringName,
    include_defaults := false
) -> bool:
    return has_theme_item(
        theme, Theme.DATA_TYPE_COLOR, name, theme_type,
        include_defaults
    )


## Returns the [Color] property defined by [param name] and [param theme_type],
## if it exists in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.[br][br]
## Returns the default color value if the property isn't found.
## Use [method has_color] to check for existence.[br][br]
## [b]Note:[/b] This method wraps [method Theme.get_color].
static func get_color(
    theme: Theme, name: StringName, theme_type: StringName,
    include_defaults := true
) -> Color:
    return get_theme_item(
        theme, Theme.DATA_TYPE_COLOR, name, theme_type,
        include_defaults
    ) as Color


## Creates or changes the value of the [Color] property defined by
## [param name] and [param theme_type] in [param theme].
## If [param value] is not valid for [param data_type] an
## appropriate fallback value will be set.[br][br]
## [b]Note:[/b] This method wraps [method Theme.set_color].
static func set_color(
    theme: Theme, name: StringName, theme_type: StringName, value: Color
) -> void:
    set_theme_item(
        theme, Theme.DATA_TYPE_COLOR,
        name, theme_type, value
    )


## Removes the [Color] property defined by [param name] and [param theme_type],
## if it exists in [param theme].[br][br]
## [b]Note:[/b] This method wraps [method Theme.clear_color] but does not fail
## if property doesn't exist. Use [method has_color] to check for existence.
static func clear_color(
    theme: Theme, name: StringName, theme_type: StringName
) -> void:
    clear_theme_item(
        theme, Theme.DATA_TYPE_COLOR,
        name, theme_type
    )


## Renames the [Color] property defined by [param old_name] and [param theme_type] to [param name],
## if it exists in [param theme].[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.[br][br]
## [b]Note:[/b] This method wraps [method Theme.rename_color] but does not fail
## if [param old_name] doesn't exist, or if a property with [param name] already exists.
## Use [method has_color] to check for existence and [method clear_color] to remove the existing property.
static func rename_color(
    theme: Theme,
    old_name: StringName, name: StringName, theme_type: StringName,
    include_defaults := true
) -> void:
    rename_theme_item(
        theme, Theme.DATA_TYPE_COLOR,
        old_name, name, theme_type,
        include_defaults
    )

#endregion

#region Constants



#endregion

#region Constants (Editor utilities)

## The type of a theme constant property.[br][br]
## [b]Note:[/b] These values are only useful for editor tools.
enum ConstantType {
    ## Unknown constant type.
    UNKNOWN = -1,
    ## The constant is a pixel measurement.
    PIXEL = 0,
    ## The constant is a multiplication factor.
    FACTOR = 1,
    ## The constant is a boolean flag.
    FLAG = 2
}

# RegEx used in [method get_constant_type].
static var _constant_type_regex := RegEx.create_from_string(
    r"(?(DEFINE)" + \
    r"(?P<p>size|height|width|margin|padding|separation|offset|spacing|thickness|border)" + \
    r"(?P<ps>bottom|top|left|right|x|y)" + \
    r"(?P<f>scale|speed)" + \
    r"(?P<b>draw|modulate|align|center))" + \
    r"^(?:(?P<pixel>(?:\w+_)*(?P>p)(?:_(?P>ps))?)|(?P<factor>(?:\w+_)*(?P>f))|(?P<flag>(?P>b)(?:_\w+)*))$"
)


## Returns an appropriate [enum ConstantType] for the constant [param name].[br][br]
## Returns [constant ConstantType.PIXEL] if [param name] ends with
## [code]size[/code], [code]height[/code], [code]width[/code],
## [code]margin[/code], [code]padding[/code],
## [code]separation[/code], [code]offset[/code], [code]spacing[/code],
## [code]thickness[/code], [code]border[/code]
## with optional suffix
## [code]_bottom[/code], [code]_top[/code], [code]_left[/code], [code]_right[/code],
## [code]_x[/code], [code]_y[/code].[br][br]
## Returns [constant ConstantType.FACTOR] if [param name] ends with
## [code]scale[/code], [code]speed[/code].[br][br]
## Returns [constant ConstantType.FLAG] if [param name] starts with
## [code]draw[/code], [code]modulate[/code], [code]align[/code], [code]center[/code]
## meaning that constant value of [code]0[/code] equals [code]false[/code] and
## constant value of [code]1[/code] equals [code]true[/code].[br][br]
## Returns [constant ConstantType.UNKNOWN] otherwise.[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
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


## Gets an appropriate suffix for the given constant [param type].[br][br]
## [b]Note:[/b] This method is only useful for editor tools.
static func get_constant_type_suffix(type: ConstantType) -> StringName:
    match type:
        ConstantType.PIXEL:  return &"px"
        ConstantType.FACTOR: return &"x"
        _:                   return &""

#endregion

#region Fonts

## Returns the font size name to pair [param font_name] with.[br]
## Used in [method has_pairing_font_size] and [method get_pairing_font_size].
static func get_pairing_font_size_name(font_name: StringName) -> StringName:
    return font_name + "_size"


## Returns [code]true[/code] if there is a font size to pair [param font_name] with.[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.
static func has_pairing_font_size(
    theme: Theme,
    font_name: StringName,
    theme_type: StringName,
    include_defaults := false
) -> bool:
    var font_size_name := get_pairing_font_size_name(font_name)
    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        if font_size_name in s.theme.get_font_size_list(s.theme_type):
            return true
    return false


## Returns the font size to pair [param font_name] with, if there is one
## or an appropriate default value if no font size pairing is found.[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.
static func get_pairing_font_size(
    theme: Theme,
    font_name: StringName,
    theme_type: StringName,
    include_defaults := true
) -> int:
    var font_size_name := get_pairing_font_size_name(font_name)
    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        if font_size_name in s.theme.get_font_size_list(s.theme_type):
            return s.theme.get_font_size(font_size_name, s.theme_type)
    return get_default_font_size(theme, include_defaults)

#endregion

#region Font Sizes

## Returns the font name to pair [param font_size_name].[br]
## Used in [method has_pairing_font] and [method get_pairing_font].
static func get_pairing_font_name(font_size_name: StringName) -> StringName:
    return font_size_name.trim_suffix("_size")


## Returns [code]true[/code] if there is a font to pair [param font_name_size] with.[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.
static func has_pairing_font(
    theme: Theme,
    font_size_name: StringName,
    theme_type: StringName,
    include_defaults := false
) -> bool:
    var font_name := get_pairing_font_name(font_size_name)
    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        if font_name in s.theme.get_font_list(s.theme_type):
            return true
    return false


## Returns the font to pair [param font_size_name] with, if there is one
## or an appropriate default value if no font pairing is found.[br][br]
## If [param include_defaults] is [code]true[/code] variation bases for [param theme_type]
## and base themes for [param theme] are included in the search.
static func get_pairing_font(
    theme: Theme,
    font_size_name: StringName,
    theme_type: StringName,
    include_defaults := true
) -> Font:
    var font_name := get_pairing_font_name(font_size_name)
    for s in DefaultsIterator.new(theme, theme_type, include_defaults):
        if font_name in s.theme.get_font_list(s.theme_type):
            return s.theme.get_font(font_name, s.theme_type)
    return get_default_font(theme, include_defaults)

#endregion

#region Icons



#endregion

#region Styleboxes



#endregion
