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
    var focus: StyleBox

    var scrollbar_h_separation: int
    var scrollbar_v_separation: int
    var scrollbar_margin_bottom: int
    var scrollbar_margin_left: int
    var scrollbar_margin_right: int
    var scrollbar_margin_top: int

    var h_separation: int
    var v_separation: int
    var inner_item_margin_bottom: int
    var inner_item_margin_left: int
    var inner_item_margin_right: int
    var inner_item_margin_top: int

    var cursor: StyleBox
    var cursor_unfocused: StyleBox
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

    var button_hover: StyleBox
    var button_pressed: StyleBox
    var button_margin: int
    var button_collapsed: Texture2D

    var max_control_panel: StyleBox
    var max_control_font: Font
    var max_control_font_size: int

    var panel_min_size: Vector2
    var panel_start_offset: Vector2
    var panel_end_offset: Vector2
    var panel_total_offset: Vector2

    var cell_start_offset: Vector2
    var cell_end_offset: Vector2
    var cell_total_offset: Vector2

    var icon_min_size: Vector2

    var header_min_size: Vector2
    var header_start_offset: Vector2
    var header_end_offset: Vector2
    var header_total_offset: Vector2

    func update(c: Control) -> void:
        panel = c.get_theme_stylebox(&"panel", &"Tree")
        focus = c.get_theme_stylebox(&"focus", &"Tree")

        scrollbar_h_separation = c.get_theme_constant(&"scrollbar_h_separation", &"Tree")
        scrollbar_v_separation = c.get_theme_constant(&"scrollbar_v_separation", &"Tree")
        scrollbar_margin_bottom = c.get_theme_constant(&"scrollbar_margin_bottom", &"Tree")
        if scrollbar_margin_bottom < 0:
            scrollbar_margin_bottom = panel.get_margin(SIDE_BOTTOM)
        scrollbar_margin_left = c.get_theme_constant(&"scrollbar_margin_left", &"Tree")
        if scrollbar_margin_left < 0:
            scrollbar_margin_left = panel.get_margin(SIDE_LEFT)
        scrollbar_margin_right = c.get_theme_constant(&"scrollbar_margin_right", &"Tree")
        if scrollbar_margin_right < 0:
            scrollbar_margin_right = panel.get_margin(SIDE_RIGHT)
        scrollbar_margin_top = c.get_theme_constant(&"scrollbar_margin_top", &"Tree")
        if scrollbar_margin_top < 0:
            scrollbar_margin_top = panel.get_margin(SIDE_TOP)

        h_separation = c.get_theme_constant(&"h_separation", &"Tree")
        v_separation = c.get_theme_constant(&"v_separation", &"Tree")
        inner_item_margin_bottom = c.get_theme_constant(&"inner_item_margin_bottom", &"Tree")
        inner_item_margin_left = c.get_theme_constant(&"inner_item_margin_left", &"Tree")
        inner_item_margin_right = c.get_theme_constant(&"inner_item_margin_right", &"Tree")
        inner_item_margin_top = c.get_theme_constant(&"inner_item_margin_top", &"Tree")

        cursor = c.get_theme_stylebox(&"cursor", &"Tree")
        cursor_unfocused = c.get_theme_stylebox(&"cursor_unfocused", &"Tree")
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

        button_hover = c.get_theme_stylebox(&"button_hover", &"Tree")
        button_pressed = c.get_theme_stylebox(&"button_pressed", &"Tree")
        button_margin = c.get_theme_constant(&"button_margin", &"Tree")
        button_collapsed = c.get_theme_icon(&"menu_hightlight", &"TabContainer")

        max_control_panel = c.get_theme_stylebox(&"normal", &"ColorPickerButton")
        max_control_font = c.get_theme_font(&"font", &"ColorPickerButton")
        max_control_font_size = c.get_theme_font_size(&"font_size", &"ColorPickerButton")

        panel_min_size = panel.get_minimum_size()
        panel_start_offset = Vector2(
            scrollbar_margin_left,
            scrollbar_margin_top
        )
        panel_end_offset = Vector2(
            scrollbar_margin_right,
            scrollbar_margin_bottom
        )
        panel_total_offset = panel_start_offset + panel_end_offset

        cell_start_offset = Vector2(
            inner_item_margin_left,
            inner_item_margin_top
        )
        cell_end_offset = Vector2(
            inner_item_margin_right,
            inner_item_margin_bottom
        )
        cell_total_offset = cell_start_offset + cell_end_offset

        icon_min_size = ThemeDB.fallback_icon.get_size() * c.get_theme_default_base_scale()

        header_start_offset = Vector2(
            h_separation,
            v_separation
        )
        header_end_offset = Vector2(
            h_separation,
            v_separation
        )
        header_total_offset = header_start_offset + header_start_offset

        header_min_size = header_total_offset + cell_total_offset
        header_min_size.x += icon_min_size.x * 2 + h_separation
        header_min_size.y += max(icon_min_size.y, font.get_height(font_size))

var _cache := _ThemeCache.new()

#endregion

class _ListItem extends Object:
    var visible: bool
    var text: String
    var control: Control

class _Header extends Object:
    var text: String
    var icon: Texture2D
    var folded: bool
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

var _v_scroll_bar: VScrollBar
var _h_scroll_bar: HScrollBar

var _header_rect: Rect2
var _header_foldout_rect: Rect2
var _header_icon_rect: Rect2
var _header_text_rect: Rect2

var _item_rect: Rect2
var _item_text_rect: Rect2
var _item_button_rect: Rect2
var _item_control_rect: Rect2


func _init() -> void:
    for data_type in Theme.DATA_TYPE_MAX:
        _headers.append(_Header.new())

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
            _update_size()
        NOTIFICATION_THEME_CHANGED:
            if not is_node_ready():
                return
            _update_headers()
            _cache.update(self)
            _update_size()
            queue_redraw()
        NOTIFICATION_RESIZED:
            _update_size()
            queue_redraw()
        NOTIFICATION_DRAW:
            var rect := Rect2(Vector2.ZERO, size)
            draw_style_box(_cache.panel, rect)

            var header_offset := _cache.header_min_size.y
            var header_rect := _header_rect
            var foldout_rect := _header_foldout_rect
            var icon_rect := _header_icon_rect
            var text_rect := _header_text_rect
            for data_type in Theme.DATA_TYPE_MAX:
                if data_type % 2 == 0:
                    draw_style_box(_cache.selected, header_rect)

                var header := _headers[data_type]
                if header.folded:
                    draw_texture_rect(_cache.arrow_collapsed, foldout_rect, false)
                else:
                    draw_texture_rect(_cache.arrow, foldout_rect, false)
                draw_texture_rect(header.icon, icon_rect, false)

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
                text_line.draw(ci, position, color)

                header_rect.position.y += header_offset
                foldout_rect.position.y += header_offset
                icon_rect.position.y += header_offset
                text_rect.position.y += header_offset

            if has_focus():
                draw_style_box(_cache.focus, rect)
        NOTIFICATION_PREDELETE:
            for data_type in Theme.DATA_TYPE_MAX:
                var header := _headers[data_type]
                for child in header.children:
                    child.free()
                header.children.clear()
                header.free()
            _headers.clear()


func _update_headers() -> void:
    for data_type in Theme.DATA_TYPE_MAX:
        var header := _headers[data_type]
        header.text = tr(ThemeUtil.get_data_type_name(data_type))
        header.icon = ThemeUtil.get_data_type_icon(data_type)


func _update_size() -> void:
    # Update basic rect cache
    var full_rect := Rect2(Vector2.ZERO, size)

    var content_rect := full_rect
    content_rect.position += _cache.panel_start_offset
    content_rect.size -= _cache.panel_total_offset

    # Update scroll bars
    var viewport_rect := content_rect

    #var content_size := get_combined_minimum_size()
    #_h_scroll_bar.visible = viewport_rect.size.x < content_size.x
    #_v_scroll_bar.visibile = viewport_rect.size.y < content_size.y

    var h_scroll_min_size := Vector2.ZERO
    if _h_scroll_bar.visible:
        h_scroll_min_size = _h_scroll_bar.get_combined_minimum_size()
        var h_scroll_offset := h_scroll_min_size.y + _cache.scrollbar_v_separation
        viewport_rect.size.y -= h_scroll_offset

    var v_scroll_min_size := Vector2.ZERO
    if _v_scroll_bar.visible:
        v_scroll_min_size = _v_scroll_bar.get_combined_minimum_size()
        var v_scroll_offset :=v_scroll_min_size.x + _cache.scrollbar_h_separation
        viewport_rect.size.x -= v_scroll_offset
        if is_layout_rtl():
            viewport_rect.position.x += v_scroll_offset

    if _v_scroll_bar.visible:
        var v_scroll_bar_rect := Rect2(
            content_rect.position.x,
            content_rect.position.y,
            v_scroll_min_size.x,
            content_rect.size.y - h_scroll_min_size.y
        )
        if not is_layout_rtl():
            v_scroll_bar_rect.position.x = content_rect.end.x - v_scroll_min_size.x

        _v_scroll_bar.position = v_scroll_bar_rect.position
        _v_scroll_bar.size = v_scroll_bar_rect.size
        _v_scroll_bar.max_value = 100.0
        _v_scroll_bar.page = 10.0

    if _h_scroll_bar.visible:
        var h_scroll_bar_rect := Rect2()
        h_scroll_bar_rect = Rect2(
            content_rect.position.x,
            content_rect.end.y - h_scroll_min_size.y,
            content_rect.size.x - v_scroll_min_size.x,
            h_scroll_min_size.y
        )
        if is_layout_rtl():
            h_scroll_bar_rect.position.x += v_scroll_min_size.x

        _h_scroll_bar.position = h_scroll_bar_rect.position
        _h_scroll_bar.size = h_scroll_bar_rect.size
        _h_scroll_bar.max_value = 100
        _h_scroll_bar.page = 10

    _header_rect = viewport_rect
    _header_rect.size.y = _cache.header_min_size.y

    var header_content_rect := _header_rect
    header_content_rect.position += _cache.header_start_offset
    header_content_rect.size -= _cache.header_total_offset

    _header_foldout_rect = header_content_rect
    _header_foldout_rect.size.x = _cache.icon_min_size.x

    _header_icon_rect = header_content_rect
    _header_icon_rect.position.x = _header_foldout_rect.end.x + _cache.h_separation
    _header_icon_rect.size.x = _cache.icon_min_size.x

    _header_text_rect = header_content_rect
    var header_text_offset := _header_foldout_rect.size.x + _header_icon_rect.size.x + _cache.h_separation * 2
    _header_text_rect.position.x += header_text_offset
    _header_text_rect.size.x -= header_text_offset

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
