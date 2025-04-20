@tool
extends Window

# https://github.com/Lenrow/line-edit-complete-godot

# https://github.com/godotengine/godot/blob/master/scene/gui/popup_menu.cpp#L241
# https://github.com/godotengine/godot/blob/master/scene/main/window.cpp#L2173

# https://github.com/godotengine/godot/blob/master/scene/gui/code_edit.h
# https://github.com/godotengine/godot/blob/master/scene/gui/code_edit.cpp
# https://github.com/godotengine/godot/blob/master/scene/gui/code_edit.cpp#L2132

# https://github.com/geegaz/Multiple-Windows-tutorial


const NodeUtil := Gonzago.NodeUtil

class ThemeCache extends RefCounted:
    var panel: StyleBox
    var hover: StyleBox

    var font: Font
    var font_size: int
    var font_color: Color
    var font_hover_color: Color

    var h_separation: int
    var v_separation: int
    var item_start_padding: int
    var item_end_padding: int

    var panel_min_size: Vector2
    var item_size: Vector2

class Item extends Object:
    var text: String
    var icon: Texture2D

    func _init(text: String, icon: Texture2D = null) -> void:
        self.text = text
        self.icon = icon


@export_range(1, 10, 1, "or_greater")
var max_lines := 10:
    set(new_max_lines):
        new_max_lines = maxi(new_max_lines, 1)
        if max_lines != new_max_lines:
            max_lines = new_max_lines
            if not NodeUtil.is_node_being_edited(self) and is_node_ready():
                _update_size()
                _apply_rect()
    get:
        return max_lines


var _theme_cache := ThemeCache.new()
var _items: Array[Item] = []
var _line_edit: LineEdit
var _panel: Control
var _scroll_bar: VScrollBar

var _max_height: float
var _rect: Rect2


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            _update_theme_cache()
            _panel = Control.new()
            _panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
            _panel.draw.connect(_draw)
            add_child(_panel)
            _scroll_bar = VScrollBar.new()
            if is_layout_rtl():
                _scroll_bar.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
            else:
                _scroll_bar.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
            add_child(_scroll_bar)

            if not NodeUtil.is_node_being_edited(self):
                # Test Data
                for i in range(15):
                    _items.append(Item.new("Test %d" % i))
                close_requested.connect(hide) # TODO: This should not be necessairy

                _update_size()
                _apply_rect()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _update_theme_cache()
                if not NodeUtil.is_node_being_edited(self):
                    _update_size()
                    _apply_rect()
        NOTIFICATION_VISIBILITY_CHANGED:
            if not NodeUtil.is_node_being_edited(self):
                #set_focused_item(-1)
                _apply_rect()
        NOTIFICATION_PARENTED:
            if NodeUtil.is_node_being_edited(self):
                update_configuration_warnings()
                return

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
        NOTIFICATION_UNPARENTED:
            if NodeUtil.is_node_being_edited(self):
                update_configuration_warnings()
                return

            if _line_edit and not NodeUtil.is_node_being_edited(self):
                if _line_edit.resized.is_connected(_resized):
                    _line_edit.resized.disconnect(_resized)
                if _line_edit.focus_entered.is_connected(_focus_entered):
                    _line_edit.focus_entered.disconnect(_focus_entered)
                if _line_edit.focus_exited.is_connected(_focus_exited):
                    _line_edit.focus_exited.disconnect(_focus_exited)
                if _line_edit.text_changed.is_connected(_text_changed):
                    _line_edit.text_changed.disconnect(_text_changed)
            _line_edit = null
        NOTIFICATION_PREDELETE:
            while not _items.is_empty():
                var item := _items.pop_back()
                item.free()


func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    var line_edit := get_parent() as LineEdit
    if not line_edit:
        warnings.append("Auto complete needs to be a child of a LineEdit.")
    return warnings


func _get_contents_minimum_size() -> Vector2:
    var min_size := _theme_cache.panel_min_size
    min_size.x += _theme_cache.item_size.x
    min_size.y += _theme_cache.item_size.y * _items.size()
    return min_size


func _draw() -> void:
    var ci := _panel.get_canvas_item()
    var rect := _panel.get_rect()
    _theme_cache.panel.draw(ci, rect)

    var content_rect := rect
    content_rect.position += _theme_cache.panel.get_offset()
    content_rect.size -= _theme_cache.panel.get_offset() + Vector2(
        _theme_cache.panel.get_margin(SIDE_RIGHT),
        _theme_cache.panel.get_margin(SIDE_BOTTOM)
    )

    # TODO: is ltr
    var line_rect := content_rect
    line_rect.size.y = _theme_cache.item_size.y

    var item_rect := line_rect
    item_rect.position.x += _theme_cache.item_start_padding
    item_rect.size.x -= _theme_cache.item_start_padding + _theme_cache.item_end_padding

    for item_idx in _items.size():
        var item := _items[item_idx]

        if item_idx % 3 == 0:
            _theme_cache.hover.draw(ci, line_rect)

        var text_line := TextLine.new()
        text_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        text_line.width = item_rect.size.x
        text_line.add_string(item.text, _theme_cache.font, _theme_cache.font_size)

        var text_size := text_line.get_size()
        var position := item_rect.position
        position.y += (item_rect.size.y - text_size.y) * 0.5

        text_line.draw(ci, position, _theme_cache.font_color)

        line_rect.position.y += line_rect.size.y
        item_rect.position.y = line_rect.position.y


func _update_theme_cache() -> void:
    _theme_cache.panel = get_theme_stylebox(&"panel", &"PopupMenu")
    _theme_cache.hover = get_theme_stylebox(&"hover", &"PopupMenu")

    _theme_cache.font = get_theme_font(&"font", &"PopupMenu")
    _theme_cache.font_size = get_theme_font_size(&"font_size", &"PopupMenu")
    _theme_cache.font_color = get_theme_color(&"font_color", &"PopupMenu")
    _theme_cache.font_hover_color = get_theme_color(&"font_hover_color", &"PopupMenu")

    _theme_cache.h_separation = get_theme_constant(&"h_separation", &"PopupMenu")
    _theme_cache.v_separation = get_theme_constant(&"v_separation", &"PopupMenu")
    _theme_cache.item_start_padding = get_theme_constant(&"item_start_padding", &"PopupMenu")
    _theme_cache.item_end_padding = get_theme_constant(&"item_end_padding", &"PopupMenu")

    _theme_cache.panel_min_size = _theme_cache.panel.get_minimum_size()
    _theme_cache.item_size = Vector2(
        _theme_cache.item_start_padding + _theme_cache.item_end_padding,
        _theme_cache.font.get_height(_theme_cache.font_size) + _theme_cache.v_separation
    )


func _update_size() -> void:
    _max_height = _theme_cache.panel_min_size.y + _theme_cache.item_size.y * max_lines
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
