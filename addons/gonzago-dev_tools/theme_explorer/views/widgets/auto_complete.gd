@tool
extends PopupMenu

# https://github.com/Lenrow/line-edit-complete-godot

# https://github.com/godotengine/godot/blob/master/scene/gui/popup_menu.cpp#L241
# https://github.com/godotengine/godot/blob/master/scene/main/window.cpp#L2173

@export_range(1, 10, 1, "or_greater")
var max_lines := 10:
    set(new_max_lines):
        new_max_lines = maxi(new_max_lines, 1)
        if max_lines != new_max_lines:
            max_lines = new_max_lines
            if is_node_ready():
                _update_size()
                _apply_rect()
    get:
        return max_lines

var _line_edit: LineEdit

var _panel_size: Vector2
var _item_size: Vector2
var _max_height: float
var _rect: Rect2


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            #unfocusable = true
            _update_theme_cache()
            _update_size()
            _apply_rect()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _update_theme_cache()
                _update_size()
                _apply_rect()
        NOTIFICATION_VISIBILITY_CHANGED:
            set_focused_item(-1)
            _apply_rect()
        NOTIFICATION_PARENTED:
            var line_edit := get_parent() as LineEdit
            if line_edit:
                if not line_edit.resized.is_connected(_resized):
                    line_edit.resized.connect(_resized)
                if not line_edit.focus_entered.is_connected(_focus_entered):
                    line_edit.focus_entered.connect(_focus_entered)
                if not line_edit.focus_exited.is_connected(_focus_exited):
                    line_edit.focus_exited.connect(_focus_exited)
                if not line_edit.text_changed.is_connected(_text_changed):
                    line_edit.text_changed.connect(_text_changed)
            if _line_edit != line_edit:
                _line_edit = line_edit
                update_configuration_warnings()
        NOTIFICATION_UNPARENTED:
            if _line_edit:
                if _line_edit.resized.is_connected(_resized):
                    _line_edit.resized.disconnect(_resized)
                if _line_edit.focus_entered.is_connected(_focus_entered):
                    _line_edit.focus_entered.disconnect(_focus_entered)
                if _line_edit.focus_exited.is_connected(_focus_exited):
                    _line_edit.focus_exited.disconnect(_focus_exited)
                if _line_edit.text_changed.is_connected(_text_changed):
                    _line_edit.text_changed.disconnect(_text_changed)
            _line_edit = null
            update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    var line_edit := get_parent() as LineEdit
    if not line_edit:
        warnings.append("Auto complete needs to be a child of a LineEdit.")
    return warnings


func _get_contents_minimum_size() -> Vector2:
    var min_size := _panel_size
    min_size.y += _item_size.y * item_count
    return min_size


func _update_theme_cache() -> void:
    _panel_size = get_theme_stylebox("panel").get_minimum_size()

    var font := get_theme_font("font")
    var font_size := get_theme_font_size("font_size")
    var font_height := font.get_height(font_size)
    var v_separation := get_theme_constant("v_separation")
    _item_size = Vector2(0.9, font_height + v_separation)


func _update_size() -> void:
    _max_height = _panel_size.y + _item_size.y * max_lines
    if not _line_edit:
        max_size.y = _max_height
        _rect = Rect2()
        return

    var line_edit_rect := _line_edit.get_rect()
    var min_size := get_contents_minimum_size()
    var max_height := _max_height

    var screen_transform := _line_edit.get_screen_transform()
    var rect := screen_transform * Rect2(
        line_edit_rect.position.x,
        line_edit_rect.end.y,
        line_edit_rect.size.x,
        min_size.y
    )

    var window := _line_edit.get_last_exclusive_window()
    var window_rect: Rect2
    if window.is_embedded():
        window_rect = window.get_visible_rect()
    else:
        var screen := window.current_screen
        window_rect = DisplayServer.screen_get_usable_rect(screen)

    if window_rect.end.y < rect.end.y:
        rect.end.y = window_rect.end.y

        var inverse_screen_transform := get_screen_transform().affine_inverse()
        var local_rect := inverse_screen_transform * rect
        max_height = minf(max_height, local_rect.size.y)

    max_size.y = max_height
    _rect = rect


func _apply_rect() -> void:
    if visible:
        position = _rect.position
        size = _rect.size


func _resized() -> void:
    _update_size()
    _apply_rect()


func _focus_entered() -> void:
    pass


func _focus_exited() -> void:
    hide()


func _text_changed(new_text: String) -> void:
    if not new_text:
        if visible:
            hide()
        return

    if not visible:
        _update_size()
        _apply_rect()
        show()
