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

class _ThemeCache extends RefCounted:
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
    var item_min_size: Vector2

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
        item_min_size = Vector2(
            item_h_padding,
            font.get_height(font_size) + v_separation
        )

class _Item extends Object:
    var text: String
    var icon: Texture2D
    var priority := -1

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
    get:
        return max_lines


var _cache := _ThemeCache.new()
var _items: Array[_Item] = []
var _candidates: Array[_Item] = []
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
            _scroll_bar.rounded = true
            _scroll_bar.custom_step = 1
            _scroll_bar.visible = false # TODO: Handle scrollbar position and visibility
            add_child(_scroll_bar)

            _cache.update(self)

            # TODO: Remove! This is test data!
            if not NodeUtil.is_node_being_edited(self):
                var default_theme := ThemeDB.get_default_theme()
                for type in default_theme.get_type_list():
                    _items.append(_Item.new(type))
                if Engine.is_editor_hint():
                    var editor_theme := EditorInterface.get_editor_theme()
                    for item in _items:
                        if editor_theme.has_icon(item.text, &"EditorIcons"):
                            item.icon = editor_theme.get_icon(item.text, &"EditorIcons")
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _cache.update(self)
                if not NodeUtil.is_node_being_edited(self) and visible:
                    _update_size()
                _panel.queue_redraw()
        NOTIFICATION_VISIBILITY_CHANGED:
            if NodeUtil.is_node_being_edited(self):
                return

            if not visible:
                _candidates.clear()
                _selected_candidate = -1
            else:
                _update_size()
                _panel.queue_redraw()
        NOTIFICATION_PARENTED:
            if NodeUtil.is_node_being_edited(self):
                update_configuration_warnings()
                return

            var line_edit := get_parent() as LineEdit
            if line_edit:
                if not line_edit.visibility_changed.is_connected(hide):
                    line_edit.visibility_changed.connect(hide)
                if not line_edit.focus_exited.is_connected(hide):
                    line_edit.focus_exited.connect(hide)
                if not line_edit.gui_input.is_connected(_gui_input):
                    line_edit.gui_input.connect(_gui_input)
                if not line_edit.text_changed.is_connected(_update_candidates):
                    line_edit.text_changed.connect(_update_candidates)
            if _line_edit != line_edit:
                _line_edit = line_edit
        NOTIFICATION_UNPARENTED:
            if NodeUtil.is_node_being_edited(self):
                update_configuration_warnings()
                return

            if _line_edit and not NodeUtil.is_node_being_edited(self):
                if _line_edit.visibility_changed.is_connected(hide):
                    _line_edit.visibility_changed.disconnect(hide)
                if _line_edit.focus_exited.is_connected(hide):
                    _line_edit.focus_exited.disconnect(hide)
                if _line_edit.gui_input.is_connected(_gui_input):
                    _line_edit.gui_input.disconnect(_gui_input)
                if _line_edit.text_changed.is_connected(_update_candidates):
                    _line_edit.text_changed.disconnect(_update_candidates)
            _line_edit = null
        NOTIFICATION_PREDELETE:
            _candidates.clear()
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
    var min_size := _cache.item_min_size
    if _scroll_bar.visible:
        var scroll_min_size := _scroll_bar.get_combined_minimum_size()
        min_size.x += scroll_min_size.x
        min_size.y = maxf(min_size.y, scroll_min_size.y)
    min_size += _cache.panel_min_size
    return min_size


# TODO: Sort this, this will make it easier
func _update_size() -> void:
    _cache.max_height = _cache.panel_min_size.y + _cache.item_min_size.y * max_lines
    if not _line_edit:
        max_size.y = _cache.max_height
        _cache.screen_rect = Rect2()
        return

    var line_edit_rect := _line_edit.get_rect()
    var min_size := get_contents_minimum_size()

    var visible_lines := mini(_candidates.size(), max_lines)
    var available_lines_height := _cache.item_min_size.y * visible_lines
    var panel_rect := Rect2(
        line_edit_rect.position.x,
        line_edit_rect.end.y,
        line_edit_rect.size.x,
        _cache.panel_min_size.y + available_lines_height
    )

    var bounding_window := _line_edit.get_last_exclusive_window()
    var bounding_rect: Rect2
    if bounding_window.is_embedded():
        bounding_rect = bounding_window.get_visible_rect()
    else:
        var screen := bounding_window.current_screen
        bounding_rect = DisplayServer.screen_get_usable_rect(screen)

    var screen_transform := _line_edit.get_screen_transform()
    var inverse_screen_transform := _line_edit.get_screen_transform().inverse()
    var local_bounding_rect := inverse_screen_transform * bounding_rect

    var final_max_height := _cache.max_height
    if local_bounding_rect.end.y < panel_rect.end.y:
        var actual_available_lines_height := local_bounding_rect.end.y - panel_rect.position.y - _cache.panel_end_offset.y
        visible_lines = floori(actual_available_lines_height / _cache.item_min_size.y)
        available_lines_height = _cache.item_min_size.y * visible_lines
        if visible_lines > 0:
            panel_rect.size.y = _cache.panel_min_size.y + available_lines_height
            final_max_height = minf(final_max_height, panel_rect.size.y)

    var screen_rect := screen_transform * panel_rect
    max_size.y = final_max_height
    _cache.screen_rect = screen_rect

    position = _cache.screen_rect.position
    size = _cache.screen_rect.size

    # Update scroll bar
    var content_rect := Rect2(Vector2.ZERO, panel_rect.size)
    content_rect.position += _cache.panel_start_offset
    content_rect.size -= _cache.panel_total_offset

    var scroll_bar_rect := Rect2()
    _scroll_bar.visible = visible_lines < _candidates.size()
    if _scroll_bar.visible:
        var scroll_min_size := _scroll_bar.get_combined_minimum_size()
        scroll_bar_rect = Rect2(
            content_rect.end.x - scroll_min_size.x,
            content_rect.position.y,
            scroll_min_size.x,
            content_rect.size.y
        )
        _scroll_bar.max_value = _candidates.size()
        _scroll_bar.page = visible_lines

        _scroll_bar.position = scroll_bar_rect.position
        _scroll_bar.size = scroll_bar_rect.size


func _update_candidates(text: String) -> void:
    _candidates.clear()
    _selected_candidate = -1
    if text.is_empty():
        hide()
        return

    for item in _items:
        item.priority = item.text.findn(text)
        if item.priority == -1:
            continue
        var idx := _candidates.bsearch_custom(item, _sort_items)
        _candidates.insert(idx, item)

    if _candidates.is_empty():
        hide()
        return

    if visible:
        _update_size()
        _panel.queue_redraw()
    else:
        show()


func _sort_items(a: _Item, b: _Item) -> bool:
    if a.priority < b.priority:
        return true
    if a.priority == b.priority:
        return a.text.naturalnocasecmp_to(b.text) < 0
    return false


func _gui_input(event: InputEvent) -> void:
    if not _line_edit.has_focus() or not visible or _candidates.is_empty():
        return

    if event.is_action_pressed(&"ui_up") and _selected_candidate > -1:
        _selected_candidate = wrapi(_selected_candidate - 1, 0, _candidates.size())
        _line_edit.accept_event()
        _panel.queue_redraw()

    if event.is_action_pressed(&"ui_down"):
        _selected_candidate = wrapi(_selected_candidate + 1, 0, _candidates.size())
        _line_edit.accept_event()
        _panel.queue_redraw()

    if event.is_action_pressed(&"ui_accept") and _selected_candidate > -1:
        _line_edit.text = _candidates[_selected_candidate].text
        _line_edit.accept_event()
        hide()


func _draw() -> void:
    var ci := _panel.get_canvas_item()
    var rect := _panel.get_rect()
    _cache.panel.draw(ci, rect)

    var content_rect := rect
    content_rect.position += _cache.panel_start_offset
    content_rect.size -= _cache.panel_total_offset

    var line_rect := content_rect
    line_rect.size.y = _cache.item_min_size.y

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
