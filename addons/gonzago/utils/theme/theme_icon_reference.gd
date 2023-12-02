@tool
class_name ThemeIconReference
extends Texture2D


## Theme texture resource.


@export
var use_editor_theme := true:
    set(value):
        if use_editor_theme != value:
            use_editor_theme = value
            _update_icon()
@export
var icon_name := "":
    set(value):
        if icon_name != value:
            icon_name = value
            _update_icon()
@export var icon_type := "EditorIcons":
    set(value):
        if icon_type != value:
            icon_type = value
            _update_icon()


var _icon: Texture2D


func _init() -> void:
    _update_icon()


func _update_icon() -> void:
    var new_icon := _get_icon_from_theme()
    if _icon != new_icon:
        _icon = new_icon
        emit_changed()


func _get_icon_from_theme() -> Texture2D:
    if use_editor_theme and Engine.is_editor_hint():
        var editor_theme := EditorInterface.get_editor_theme()
        if editor_theme.has_icon(icon_name, icon_type):
            return editor_theme.get_icon(icon_name, icon_type)

    var project_theme := ThemeDB.get_project_theme()
    if project_theme and project_theme.has_icon(icon_name, icon_type):
        return project_theme.get_icon(icon_name, icon_type)

    var default_theme := ThemeDB.get_default_theme()
    if default_theme.has_icon(icon_name, icon_type):
        return default_theme.get_icon(icon_name, icon_type)

    return ThemeDB.fallback_icon


func _get_height() -> int:
    if not _icon:
        return 0
    return _icon.get_height()


func _get_width() -> int:
    if not _icon:
        return 0
    return _icon.get_width()


func _has_alpha() -> bool:
    if not _icon:
        return true
    return _icon.has_alpha()


func _is_pixel_opaque(x: int, y: int) -> bool:
    if not _icon:
        return false
    return _icon.get_image().get_pixel(x, y).a == 1.0


func _draw(
    to_canvas_item: RID,
    pos: Vector2,
    modulate: Color,
    transpose: bool
) -> void:
    if _icon:
        _icon.draw(
            to_canvas_item,
            pos,
            modulate,
            transpose
        )


func _draw_rect(
    to_canvas_item: RID,
    rect: Rect2,
    tile: bool,
    modulate: Color,
    transpose: bool
) -> void:
    if _icon:
        _icon.draw_rect(
            to_canvas_item,
            rect,
            tile,
            modulate,
            transpose
        )


func _draw_rect_region(
    to_canvas_item: RID,
    rect: Rect2,
    src_rect: Rect2,
    modulate: Color,
    transpose: bool,
    clip_uv: bool
) -> void:
    if _icon:
        _icon.draw_rect_region(
            to_canvas_item,
            rect,
            src_rect,
            modulate,
            transpose,
            clip_uv
        )
