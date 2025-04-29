@tool
extends Control

# https://github.com/godotengine/godot/blob/master/scene/gui/tree.h
# https://github.com/godotengine/godot/blob/master/scene/gui/tree.cpp
# https://github.com/godotengine/godot/blob/master/scene/gui/item_list.h
# https://github.com/godotengine/godot/blob/master/scene/gui/item_list.cpp
# https://github.com/godotengine/godot/blob/master/scene/gui/tree.cpp#L3603
# https://github.com/godotengine/godot/blob/master/scene/gui/tree.cpp#L4379

signal data_type_selected(data_type: Theme.DataType, theme_type: StringName)
signal theme_item_selected(data_type: Theme.DataType, theme_type: StringName, theme_item: StringName)

const NodeUtil := Gonzago.NodeUtil
const ThemeUtil := preload("uid://rmaosngaa4f5")

enum DisplayMode {
    DISPLAY_MODE_LIST,
    DISPLAY_MODE_THUMBNAIL
}

#region Theme

class _ThemeCache extends RefCounted:
    var panel: StyleBox
    var panel_ofs_start: Vector2
    var panel_ofs_end: Vector2
    var panel_ofs: Vector2
    var focus: StyleBox

    var scrollbar_separation: Vector2
    var scrollbar_ofs_start: Vector2
    var scrollbar_ofs_end: Vector2

    var separation: Vector2
    var cell_ofs_start: Vector2
    var cell_ofs_end: Vector2
    var cell_ofs: Vector2
    var item_margin: int

    var hovered: StyleBox
    var hovered_dimmed: StyleBox
    var selected: StyleBox
    var selected_focus: StyleBox

    var font: Font
    var font_size: int
    var font_color: Color
    var font_disabled_color: Color
    var font_hovered_color: Color
    var font_hovered_dimmed_color: Color
    var font_selected_color: Color

    var outline_size: int
    var font_outline_color: Color

    var arrow: Texture2D
    var arrow_collapsed: Texture2D
    var arrow_collapsed_mirrored: Texture2D
    var arrow_size: Vector2

    func get_arrow(expanded: bool, rtl: bool) -> Texture2D:
        if expanded:
            return arrow
        return arrow_collapsed_mirrored if rtl else arrow_collapsed

    var button_hover: StyleBox
    var button_pressed: StyleBox
    var button_margin: int
    var button_collapsed: Texture2D

    var icon_size: int
    var thumb_size: int

    var cell_min_size: Vector2

    func update(c: Control) -> void:
        panel = c.get_theme_stylebox(&"panel", &"Tree")
        panel_ofs_start = Vector2(
            panel.get_margin(SIDE_LEFT),
            panel.get_margin(SIDE_TOP)
        )
        panel_ofs_end = Vector2(
            panel.get_margin(SIDE_RIGHT),
            panel.get_margin(SIDE_BOTTOM)
        )
        panel_ofs = panel_ofs_start + panel_ofs_end
        focus = c.get_theme_stylebox(&"focus", &"Tree")

        scrollbar_separation = Vector2(
            c.get_theme_constant(&"scrollbar_h_separation", &"Tree"),
            c.get_theme_constant(&"scrollbar_v_separation", &"Tree")
        )
        scrollbar_ofs_start = Vector2(
            c.get_theme_constant(&"scrollbar_margin_left", &"Tree"),
            c.get_theme_constant(&"scrollbar_margin_top", &"Tree")
        )
        if scrollbar_ofs_start.x < 0:
            scrollbar_ofs_start.x = panel_ofs_start.x
        if scrollbar_ofs_start.y < 0:
            scrollbar_ofs_start.y = panel_ofs_start.y
        scrollbar_ofs_end = Vector2(
            c.get_theme_constant(&"scrollbar_margin_right", &"Tree"),
            c.get_theme_constant(&"scrollbar_margin_bottom", &"Tree")
        )
        if scrollbar_ofs_end.x < 0:
            scrollbar_ofs_end.x = panel_ofs_end.x
        if scrollbar_ofs_end.y < 0:
            scrollbar_ofs_end.y = panel_ofs_end.y

        separation = Vector2(
            c.get_theme_constant(&"h_separation", &"Tree"),
            c.get_theme_constant(&"v_separation", &"Tree")
        )
        cell_ofs_start = Vector2(
            c.get_theme_constant(&"inner_item_margin_left", &"Tree"),
            c.get_theme_constant(&"inner_item_margin_top", &"Tree")
        )
        cell_ofs_end = Vector2(
            c.get_theme_constant(&"inner_item_margin_right", &"Tree"),
            c.get_theme_constant(&"inner_item_margin_bottom", &"Tree")
        )
        cell_ofs = cell_ofs_start + cell_ofs_end
        item_margin = c.get_theme_constant(&"item_margin", &"Tree")

        hovered = c.get_theme_stylebox(&"hovered", &"Tree")
        hovered_dimmed = c.get_theme_stylebox(&"hovered_dimmed", &"Tree")
        selected = c.get_theme_stylebox(&"selected", &"Tree")
        selected_focus = c.get_theme_stylebox(&"selected_focus", &"Tree")

        font = c.get_theme_font(&"font", &"Tree")
        font_size = c.get_theme_font_size(&"font_size", &"Tree")
        font_color = c.get_theme_color(&"font_color", &"Tree")
        font_disabled_color = c.get_theme_color(&"font_disabled_color", &"Tree")
        font_hovered_color = c.get_theme_color(&"font_hovered_color", &"Tree")
        font_hovered_dimmed_color = c.get_theme_color(&"font_hovered_dimmed_color", &"Tree")
        font_selected_color = c.get_theme_color(&"font_selected_color", &"Tree")

        outline_size = c.get_theme_constant(&"outline_size", &"Tree")
        font_outline_color = c.get_theme_color(&"font_outline_color", &"Tree")

        arrow = c.get_theme_icon(&"arrow", &"Tree")
        arrow_collapsed = c.get_theme_icon(&"arrow_collapsed", &"Tree")
        arrow_collapsed_mirrored = c.get_theme_icon(&"arrow_collapsed_mirrored", &"Tree")
        arrow_size = arrow.get_size()

        button_hover = c.get_theme_stylebox(&"button_hover", &"Tree")
        button_pressed = c.get_theme_stylebox(&"button_pressed", &"Tree")
        button_margin = c.get_theme_constant(&"button_margin", &"Tree")
        button_collapsed = c.get_theme_icon(&"menu_hightlight", &"TabContainer")

        icon_size = c.get_theme_constant(&"class_icon_size", &"Editor")
        if icon_size <= 0:
            icon_size = ThemeDB.fallback_icon.get_width()

        thumb_size = c.get_theme_constant(&"thumb_size", &"Editor")
        if thumb_size <= 0:
            thumb_size = icon_size * 4

        var font_height := font.get_height(font_size)
        var control_height := c.get_theme_constant(&"color_picker_button_height", &"Editor") - cell_ofs.y
        cell_min_size = Vector2(
            thumb_size,
            max(font_height, control_height, icon_size)
        ) + cell_ofs

var _cache := _ThemeCache.new()

#endregion

class _ListItem extends Object:
    var visible: bool = true
    var text: String
    var control: Control

class _Header extends Object:
    var text: String
    var icon: Texture2D
    var expanded: bool = true
    var children: Array[_ListItem] = []

    func has_visible_children() -> bool:
        for child in children:
            if child.visible:
                return true
        return false

    func get_visible_children_count() -> int:
        var count := 0
        for child in children:
            if child.visible:
                count += 1
        return count

var _headers: Array[_Header] = []
var _theme: Theme = null
var _theme_type: StringName = StringName()

#var _panel: Container
var _v_scroll_bar: VScrollBar
var _h_scroll_bar: HScrollBar
var _scroll_ofs: Vector2

var _full_rect: Rect2
var _viewport_rect: Rect2
var _content_size: Vector2
var _line_rect: Rect2
var _cell_rect: Rect2
var _columns: int = 1

func _init() -> void:
    for data_type in Theme.DATA_TYPE_MAX:
        _headers.append(_Header.new())

    clip_contents = true

    #_panel = Container.new()
    #_panel.draw.connect(_draw_panel)
    #_panel.resized.connect(_panel_resized)
    #_panel.pre_sort_children.connect(_presort_panel_children)
    #_panel.sort_children.connect(_sort_panel_children)
    #add_child(_panel, false, Node.INTERNAL_MODE_FRONT)

    _v_scroll_bar = VScrollBar.new()
    #_v_scroll_bar.visible = false
    _v_scroll_bar.value_changed.connect(
        func(value: float) -> void:
            queue_redraw()
    )
    add_child(_v_scroll_bar, false, Node.INTERNAL_MODE_BACK)

    _h_scroll_bar = HScrollBar.new()
    #_h_scroll_bar.visible = false
    _h_scroll_bar.value_changed.connect(
        func(value: float) -> void:
            queue_redraw()
    )
    add_child(_h_scroll_bar, false, Node.INTERNAL_MODE_BACK)


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            _update_headers()
            _cache.update(self)
            if _theme and _theme_type:
                inspect(_theme, _theme_type)
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _update_headers()
                _cache.update(self)
                _update_size()
        NOTIFICATION_RESIZED:
            if is_node_ready():
                _update_size()
        NOTIFICATION_PREDELETE:
            for data_type in Theme.DATA_TYPE_MAX:
                var header := _headers[data_type]
                for child in header.children:
                    child.free()
                header.children.clear()
                header.free()
            _headers.clear()


func inspect(theme: Theme, theme_type: StringName) -> void:
    _theme = theme
    _theme_type = theme_type
    if not is_node_ready():
        return

    for data_type in Theme.DATA_TYPE_MAX:
        var header := _headers[data_type]
        for child in header.children:
            child.free()
        header.children.clear()

    if _theme and _theme_type:
        for data_type in Theme.DATA_TYPE_MAX:
            var header := _headers[data_type]
            var theme_items := ThemeUtil.get_theme_item_list(_theme, data_type, _theme_type)
            for theme_item in theme_items:
                var item := _ListItem.new()
                item.text = theme_item
                header.children.append(item)

    _update_size()
    queue_redraw()


func _update_headers() -> void:
    for data_type in Theme.DATA_TYPE_MAX:
        var header := _headers[data_type]
        header.text = tr(ThemeUtil.get_data_type_name(data_type))
        header.icon = ThemeUtil.get_data_type_icon(data_type)


func _update_size() -> void:
    # Update basic rect cache
    _full_rect = Rect2(Vector2.ZERO, size)

    var full_rect_with_ofs := _full_rect
    full_rect_with_ofs.position += _cache.panel_ofs_start
    full_rect_with_ofs.size -= _cache.panel_ofs

    _viewport_rect = full_rect_with_ofs

    var lines_count := 0
    for data_type in Theme.DATA_TYPE_MAX:
        var header := _headers[data_type]
        var visible_children := header.get_visible_children_count()
        if visible_children > 0:
            lines_count += 1
            lines_count += visible_children
    lines_count = maxi(1, lines_count)

    # Update scroll bars

    #var content_size := get_combined_minimum_size()
    #_h_scroll_bar.visible = viewport_rect.size.x < content_size.x
    #_v_scroll_bar.visibile = viewport_rect.size.y < content_size.y

    var h_scroll_min_size := Vector2.ZERO
    if _h_scroll_bar.visible:
        h_scroll_min_size = _h_scroll_bar.get_combined_minimum_size()
        var h_scroll_offset := h_scroll_min_size.y + _cache.scrollbar_separation.y
        _viewport_rect.size.y -= h_scroll_offset

    var v_scroll_min_size := Vector2.ZERO
    if _v_scroll_bar.visible:
        v_scroll_min_size = _v_scroll_bar.get_combined_minimum_size()
        var v_scroll_offset := v_scroll_min_size.x + _cache.scrollbar_separation.x
        _viewport_rect.size.x -= v_scroll_offset
        if is_layout_rtl():
            _viewport_rect.position.x += v_scroll_offset

    if _v_scroll_bar.visible:
        var v_scroll_bar_rect := full_rect_with_ofs
        v_scroll_bar_rect.size.x = v_scroll_min_size.x
        v_scroll_bar_rect.size.y -= h_scroll_min_size.y
        if not is_layout_rtl():
            v_scroll_bar_rect.position.x = full_rect_with_ofs.end.x - v_scroll_min_size.x

        _v_scroll_bar.position = v_scroll_bar_rect.position
        _v_scroll_bar.size = v_scroll_bar_rect.size
        _v_scroll_bar.max_value = _content_size.y
        _v_scroll_bar.page = _viewport_rect.size.y

    if _h_scroll_bar.visible:
        var h_scroll_bar_rect := Rect2(
            full_rect_with_ofs.position.x,
            full_rect_with_ofs.end.y - h_scroll_min_size.y,
            full_rect_with_ofs.size.x - v_scroll_min_size.x,
            h_scroll_min_size.y
        )
        if is_layout_rtl():
            h_scroll_bar_rect.position.x += v_scroll_min_size.x

        _h_scroll_bar.position = h_scroll_bar_rect.position
        _h_scroll_bar.size = h_scroll_bar_rect.size
        _h_scroll_bar.max_value = _content_size.x
        _h_scroll_bar.page = _viewport_rect.size.x

    _line_rect = _viewport_rect
    _line_rect.size.y = _cache.cell_min_size.y

    _content_size = _viewport_rect.size
    _content_size.y = lines_count * _line_rect.size.y

# TODO:
#    var full_width := 1000.0
#    var cell_min_width := 100.0
#    var cell_h_separation := 1.0
#    var columns := 1
#    var expanded_cell_width := cell_min_width
#    if full_width > cell_min_width:
#        var adjusted_full_width := full_width + cell_h_separation
#        var adjusted_cell_min_width := cell_min_width + cell_h_separation
#        columns = floori(adjusted_full_width / adjusted_cell_min_width)
#        expanded_cell_width = (adjusted_full_width / columns) - cell_h_separation

# TODO: Make grid, store cell span in group
    #       cell height is based on item height,
    #       cell width is also based on item height but as width or
    #       based on half thumn width?
    #       collapse buttons into popup menu if more than one?
    #       make label editable if not default? buttons next to it (will take one cell height)
    #       store in group if item control is visible (will take one cell height)
    #       group stores cell width span (1-3), group stores preview cell height span (0-3?)
    #       order in thumb mode is preview, control, editable label + buttons (collapsed)
    #       order in list mode is editable label + buttons (not collapsed), control
    #       store control width ratio in group?
    #       store callback for preview drawing in group (control and rect)? add function to force redraw?
    #       always expand when scroll is not visible to avoid massive reordering
    #       add text when no items are visible
    #       add text when no items are present
    #       autohide groups when no visible children
    #       add tooltip callback? (to group?)
    #       add context menu callback? (to group?)

func _draw() -> void:
    draw_style_box(_cache.panel, _full_rect)

    var line_rect := _line_rect
    var line_content_rect := line_rect
    line_content_rect.position += _cache.cell_ofs_start
    line_content_rect.size -= _cache.cell_ofs

    var header_count := 0
    for data_type in Theme.DATA_TYPE_MAX:
        var header := _headers[data_type]
        if not header.has_visible_children():
            continue
        header_count += 1

        _draw_header(header, line_rect)
        line_rect.position.y += line_rect.size.y

        for child in header.children:
            _draw_item(child, line_rect)
            line_rect.position.y += line_rect.size.y

    if header_count == 0:
        pass # TODO: Draw no items message

    if has_focus():
        draw_style_box(_cache.focus, _full_rect)

func _draw_header(header: _Header, rect: Rect2) -> void:
    var test_sb := get_theme_stylebox(&"bg_group_note", &"EditorProperty")
    draw_style_box(test_sb, rect)

    if false:
        draw_style_box(_cache.selected, rect)

    var content_rect := rect
    content_rect.position.y += _cache.cell_ofs_start.y
    content_rect.size -= _cache.cell_ofs

    var foldout_rect := Rect2(
        content_rect.position.x,
        content_rect.position.y + (content_rect.size.y - _cache.arrow_size.y) * 0.5,
        _cache.arrow_size.x,
        _cache.arrow_size.y
    )
    var arrow := _cache.get_arrow(header.expanded, is_layout_rtl())
    draw_texture_rect(arrow, foldout_rect, false)

    var icon_rect = Rect2(
        foldout_rect.end.x + _cache.separation.x,
        content_rect.position.y + (content_rect.size.y - _cache.icon_size) * 0.5,
        _cache.icon_size,
        _cache.icon_size
    )
    draw_texture_rect(header.icon, icon_rect, false)

    var text_rect := content_rect
    var text_offset: float = foldout_rect.size.x + icon_rect.size.x + _cache.separation.x * 2.0
    text_rect.position.x += text_offset
    text_rect.size.x -= text_offset

    var ci := get_canvas_item()
    var text_line := TextLine.new()
    text_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    text_line.width = text_rect.size.x
    text_line.add_string(header.text, _cache.font, _cache.font_size)
    var text_size := text_line.get_size()
    var position := text_rect.position
    position.y += (text_rect.size.y - text_size.y) * 0.5
    if _cache.outline_size > 0:
        text_line.draw_outline(
            ci, position,
            _cache.outline_size, _cache.font_outline_color
        )
    var color := _cache.font_color
    if false:
        color = _cache.font_selected_color
    text_line.draw(ci, position, color)

func _draw_item(item: _ListItem, rect: Rect2) -> void:
    var content_rect := rect
    content_rect.position += _cache.cell_ofs_start
    content_rect.size -= _cache.cell_ofs
    content_rect.position.x += _cache.item_margin
    content_rect.size.x -= _cache.item_margin

    var text_rect := content_rect

    var ci := get_canvas_item()
    var text_line := TextLine.new()
    text_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    text_line.width = text_rect.size.x
    text_line.add_string(item.text, _cache.font, _cache.font_size)
    var text_size := text_line.get_size()
    var position := text_rect.position
    position.y += (text_rect.size.y - text_size.y) * 0.5
    if _cache.outline_size > 0:
        text_line.draw_outline(
            ci, position,
            _cache.outline_size, _cache.font_outline_color
        )
    var color := _cache.font_color
    if false:
        color = _cache.font_selected_color
    text_line.draw(ci, position, color)
