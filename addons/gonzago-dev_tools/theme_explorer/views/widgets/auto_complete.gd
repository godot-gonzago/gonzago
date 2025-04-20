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

    var font_outline_color: Color
    var outline_size: int

    var h_separation: int
    var v_separation: int
    var item_start_padding: int
    var item_end_padding: int

    var panel_min_size: Vector2
    var panel_start_offset: Vector2
    var panel_end_offset: Vector2
    var panel_total_offset: Vector2
    var item_h_padding: int
    var item_size: Vector2

    var screen_rect: Rect2
    var max_height: float

    func update(c: Window) -> void:
        panel = c.get_theme_stylebox(&"panel", &"PopupMenu")
        hover = c.get_theme_stylebox(&"hover", &"PopupMenu")

        font = c.get_theme_font(&"font", &"PopupMenu")
        font_size = c.get_theme_font_size(&"font_size", &"PopupMenu")
        font_color = c.get_theme_color(&"font_color", &"PopupMenu")
        font_hover_color = c.get_theme_color(&"font_hover_color", &"PopupMenu")

        font_outline_color = c.get_theme_color(&"font_outline_color", &"PopupMenu")
        outline_size = c.get_theme_constant(&"outline_size", &"PopupMenu")

        h_separation = c.get_theme_constant(&"h_separation", &"PopupMenu")
        v_separation = c.get_theme_constant(&"v_separation", &"PopupMenu")
        item_start_padding = c.get_theme_constant(&"item_start_padding", &"PopupMenu")
        item_end_padding = c.get_theme_constant(&"item_end_padding", &"PopupMenu")

        panel_min_size = panel.get_minimum_size()
        panel_start_offset = panel.get_offset()
        panel_end_offset = Vector2(
            panel.get_margin(SIDE_RIGHT),
            panel.get_margin(SIDE_BOTTOM)
        )
        panel_total_offset = panel_start_offset + panel_end_offset
        item_h_padding = item_start_padding + item_end_padding
        item_size = Vector2(
            item_h_padding,
            font.get_height(font_size) + v_separation
        )

class Item extends Object:
    var text: String
    var icon: Texture2D
    var similarity := 1.0

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


var _cache := ThemeCache.new()
var _items: Array[Item] = []
var _candidates: Array[Item] = []
var _selected_candidate := -1
var _line_edit: LineEdit
var _panel: Control
var _scroll_bar: VScrollBar


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            _panel = Control.new()
            _panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
            _panel.draw.connect(_draw)
            add_child(_panel)

            _scroll_bar = VScrollBar.new()
            _scroll_bar.visible = false # TODO: Handle scrollbar position and visibility
            add_child(_scroll_bar)

            _cache.update(self)

            if not NodeUtil.is_node_being_edited(self):
                # Test Data
                for i in range(15):
                    _items.append(Item.new("Test %d" % i))
                close_requested.connect(hide) # TODO: This should not be necessairy

                _update_size()
                _apply_rect()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _cache.update(self)
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
                if not line_edit.gui_input.is_connected(_gui_input):
                    line_edit.gui_input.connect(_gui_input)
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
                if _line_edit.gui_input.is_connected(_gui_input):
                    _line_edit.gui_input.disconnect(_gui_input)
                if _line_edit.text_changed.is_connected(_text_changed):
                    _line_edit.text_changed.disconnect(_text_changed)
            _line_edit = null
        NOTIFICATION_PREDELETE:
            for idx in _items.size():
                _items[idx].free()
            _items.clear()


func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    var line_edit := get_parent() as LineEdit
    if not line_edit:
        warnings.append("Auto complete needs to be a child of a LineEdit.")
    return warnings


func _get_contents_minimum_size() -> Vector2:
    var min_size := _cache.panel_min_size
    min_size.x += _cache.item_size.x
    min_size.y += _cache.item_size.y * _candidates.size()
    return min_size


func _draw() -> void:
    var ci := _panel.get_canvas_item()
    var rect := _panel.get_rect()
    _cache.panel.draw(ci, rect)

    var content_rect := rect
    content_rect.position += _cache.panel_start_offset
    content_rect.size -= _cache.panel_total_offset

    var line_rect := content_rect
    line_rect.size.y = _cache.item_size.y

    var item_rect := line_rect
    if is_layout_rtl():
        item_rect.position.x += _cache.item_end_padding
    else:
        item_rect.position.x += _cache.item_start_padding
    item_rect.size.x -= _cache.item_h_padding

    for idx in _candidates.size():
        var item := _candidates[idx]
        if idx == _selected_candidate:
            _cache.hover.draw(ci, line_rect)

        var text_line := TextLine.new()
        text_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
        text_line.width = item_rect.size.x
        text_line.add_string(item.text, _cache.font, _cache.font_size)

        var text_size := text_line.get_size()
        var position := item_rect.position
        position.y += (item_rect.size.y - text_size.y) * 0.5

        if _cache.outline_size > 0:
            text_line.draw_outline(ci, position, _cache.outline_size, _cache.font_outline_color)
        text_line.draw(ci, position, _cache.font_color)

        line_rect.position.y += line_rect.size.y
        item_rect.position.y = line_rect.position.y


func _update_size() -> void:
    _cache.max_height = _cache.panel_min_size.y + _cache.item_size.y * max_lines
    if not _line_edit:
        max_size.y = _cache.max_height
        _cache.screen_rect = Rect2()
        return

    var line_edit_rect := _line_edit.get_rect()
    var min_size := get_contents_minimum_size()

    var screen_transform := _line_edit.get_screen_transform()
    var screen_rect := screen_transform * Rect2(
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

    var clamped_max_height := _cache.max_height
    if window_rect.end.y < screen_rect.end.y:
        screen_rect.end.y = window_rect.end.y

        var inverse_screen_transform := get_screen_transform().affine_inverse()
        var local_rect := inverse_screen_transform * screen_rect
        clamped_max_height = minf(clamped_max_height, local_rect.size.y)

    max_size.y = clamped_max_height
    _cache.screen_rect = screen_rect


func _apply_rect() -> void:
    if visible:
        position = _cache.screen_rect.position
        size = _cache.screen_rect.size


func _update_candidates(text: String) -> void:
    _candidates.clear()
    if text.is_empty():
        return

    if text.length() > 2:
        for item in _items:
            item.similarity = item.text.similarity(text)
            if item.similarity > 0.0:
                _candidates.append(item)
    else:
        for item in _items:
            item.similarity = -item.text.findn(text)
            if item.similarity < 1:
                _candidates.append(item)

    _candidates.sort_custom(
        func(a: Item, b: Item) -> bool:
            if a.similarity != b.similarity:
                return a.similarity > b.similarity
            return a.text.naturalnocasecmp_to(b.text) < 0
    )

    _selected_candidate = -1


func _resized() -> void:
    _update_size()
    _apply_rect()


func _focus_entered() -> void:
    pass


func _focus_exited() -> void:
    hide()

func _gui_input(event: InputEvent) -> void:
    if not visible or _candidates.is_empty():
        return

    if event.is_action_pressed(&"ui_up") and _selected_candidate > -1:
        _selected_candidate = wrapi(_selected_candidate - 1, 0, _candidates.size() - 1)
        _line_edit.accept_event()
        _panel.queue_redraw()

    if event.is_action_pressed(&"ui_down"):
        _selected_candidate = wrapi(_selected_candidate + 1, 0, _candidates.size() - 1)
        _line_edit.accept_event()
        _panel.queue_redraw()

    if event.is_action_pressed(&"ui_accept") and _selected_candidate > -1:
        _line_edit.text = _candidates[_selected_candidate].text
        _line_edit.accept_event()
        hide()



func _text_changed(new_text: String) -> void:
    _update_candidates(new_text)

    if _candidates.is_empty():
        if visible:
            hide()
        return

    _update_size()
    _apply_rect()
    if not visible:
        show()
