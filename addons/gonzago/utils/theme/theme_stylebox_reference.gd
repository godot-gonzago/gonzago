@tool
class_name ThemeStyleboxReference
extends StyleBox


## Theme stylebox resource.


@export
var use_editor_theme := true:
    set(value):
        if use_editor_theme != value:
            use_editor_theme = value
            _update_sb()
@export
var stylebox_name := "":
    set(value):
        if stylebox_name != value:
            stylebox_name = value
            _update_sb()
@export var stylebox_type := "EditorStyles":
    set(value):
        if stylebox_type != value:
            stylebox_type = value
            _update_sb()


var _sb: StyleBox


func _init() -> void:
    _update_sb()


func _update_sb() -> void:
    var new_sb := _get_sb_from_theme()
    if _sb != new_sb:
        _sb = new_sb
        content_margin_bottom = _sb.content_margin_bottom
        content_margin_left = _sb.content_margin_left
        content_margin_right = _sb.content_margin_right
        content_margin_top = _sb.content_margin_top
        emit_changed()


func _get_sb_from_theme() -> StyleBox:
    if use_editor_theme and Engine.is_editor_hint():
        var editor_theme := EditorInterface.get_editor_theme()
        if editor_theme.has_stylebox(stylebox_name, stylebox_type):
            return editor_theme.get_stylebox(stylebox_name, stylebox_type)

    var project_theme := ThemeDB.get_project_theme()
    if project_theme and project_theme.has_stylebox(stylebox_name, stylebox_type):
        return project_theme.get_stylebox(stylebox_name, stylebox_type)

    var default_theme := ThemeDB.get_default_theme()
    if default_theme.has_stylebox(stylebox_name, stylebox_type):
        return default_theme.get_stylebox(stylebox_name, stylebox_type)

    return ThemeDB.fallback_stylebox


func _get_minimum_size() -> Vector2:
    if not _sb:
        return Vector2.ZERO
    return _sb.get_minimum_size()


func _get_draw_rect(rect: Rect2) -> Rect2:
    if not _sb:
        return rect
    return rect.grow_individual(
        -_sb.get_margin(SIDE_LEFT),
        -_sb.get_margin(SIDE_TOP),
        -_sb.get_margin(SIDE_RIGHT),
        -_sb.get_margin(SIDE_BOTTOM)
    )


func _test_mask(point: Vector2, rect: Rect2) -> bool:
    if not _sb:
        return false
    return _sb.test_mask(point, rect)


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
    if _sb:
        _sb.draw(to_canvas_item, rect)
