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
const ThemePropertiesUtil := preload("uid://cquh4vm0q62u7")

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
    var icon_max_width: int

    var panel_min_size: Vector2
    var panel_start_offset: Vector2
    var panel_end_offset: Vector2
    var panel_total_offset: Vector2
    var item_h_padding: int
    var item_min_size: Vector2

    var screen_rect: Rect2
    var visible_items: int

    var panel_rect: Rect2
    var content_rect: Rect2
    var scroll_bar_rect: Rect2

    var item_rect: Rect2
    var icon_rect: Rect2
    var text_rect: Rect2

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
        icon_max_width = c.get_theme_constant(&"icon_max_with", &"PopupMenu")

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

    func _init(text: String = "", icon: Texture2D = null) -> void:
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

@export
var select_all_on_submit := true


var _cache := _ThemeCache.new()
var _items: Array[_Item] = []
var _candidates: Array[_Item] = []
var _selected_candidate := -1
var _is_submiting := false
var _line_edit: LineEdit
var _panel: Control
var _scroll_bar: VScrollBar


func _init() -> void:
    transient = true
    unresizable = true
    borderless = true
    transparent = true
    transparent_bg = true
    unfocusable = true


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
            _scroll_bar.visible = false
            _scroll_bar.value_changed.connect(
                func(value: float) -> void:
                    _panel.queue_redraw()
            )
            add_child(_scroll_bar)

            set_process_input(false)
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
                set_process_input(false)
                _candidates.clear()
                _selected_candidate = -1
                _scroll_bar.value = 0
            else:
                _update_size()
                _panel.queue_redraw()
        NOTIFICATION_VP_MOUSE_ENTER:
            if not NodeUtil.is_node_being_edited(self):
                set_process_input(true)
                print("Mouse entered")
        NOTIFICATION_VP_MOUSE_EXIT:
            if not NodeUtil.is_node_being_edited(self):
                set_process_input(false)
                print("Mouse exited")
        NOTIFICATION_PARENTED:
            if NodeUtil.is_node_being_edited(self):
                update_configuration_warnings()
                return

            var line_edit := get_parent() as LineEdit
            if line_edit:
                if not line_edit.visibility_changed.is_connected(hide):
                    line_edit.visibility_changed.connect(hide)
                if not line_edit.focus_entered.is_connected(_gained_focus):
                    line_edit.focus_entered.connect(_gained_focus)
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
                if _line_edit.focus_entered.is_connected(_gained_focus):
                    _line_edit.focus_entered.disconnect(_gained_focus)
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


func _validate_property(property: Dictionary) -> void:
    var property_name := property.get("name", &"") as StringName
    match property_name:
        "transient", "exclusive", "unresizable", "borderless", \
        "transparent", "transparent_bg", "unfocusable":
            var property_usage := PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
            property["usage"] = property_usage


func _property_can_revert(property: StringName) -> bool:
    if property.begins_with("item_"):
        var split := property.split("/")
        if split.size() < 2:
            return false
        if not split[0].trim_prefix("item_").is_valid_int():
            return false
        match split[1]:
            &"text", &"icon": return true
        return false

    if ThemePropertiesUtil.is_theme_override_property(property):
        return true
    return false


func _property_get_revert(property: StringName) -> Variant:
    if property.begins_with("item_"):
        var split := property.split("/")
        if split.size() < 2:
            return false
        if not split[0].trim_prefix("item_").is_valid_int():
            return false
        if split[1] == &"text":
            return ""
        return null

    return null


func _set(property: StringName, value: Variant) -> bool:
    if property == &"item_count":
        var old_size := _items.size()
        var new_size := int(value)
        if old_size > new_size:
            for i in range(old_size - 1, new_size - 1, -1):
                _items[i].free()
            _items.resize(new_size)
            notify_property_list_changed()
        elif old_size < new_size:
            _items.resize(new_size)
            for i in range(old_size, new_size):
                _items[i] = _Item.new()
            notify_property_list_changed()
        return true

    if property.begins_with("item_"):
        var split := property.split("/")
        if split.size() < 2:
            return false
        var str_idx := split[0].trim_prefix("item_")
        if not str_idx.is_valid_int():
            return false
        var idx := int(str_idx)
        if not _items[idx]:
            _items[idx] = _Item.new()
        match split[1]:
            &"text":
                _items[idx].text = str(value)
                return true
            &"icon":
                _items[idx].icon = value as Texture2D
                return true
        return false

    return ThemePropertiesUtil.set_theme_override_property(self, property, value)


func _get(property: StringName) -> Variant:
    if property == &"item_count":
        return _items.size()

    if property.begins_with("item_"):
        var split := property.split("/")
        if split.size() < 2:
            return null
        var str_idx := split[0].trim_prefix("item_")
        if not str_idx.is_valid_int():
            return null
        var idx := int(str_idx)
        if not _items[idx]:
            _items[idx] = _Item.new()
        match split[1]:
            &"text": return _items[idx].text
            &"icon": return _items[idx].icon
        return null

    return ThemePropertiesUtil.get_theme_override_property(self, property)


func _get_property_list() -> Array[Dictionary]:
    var properties: Array[Dictionary] = []

    properties.append({
        "name": &"item_count",
        "class_name": "Items,item_",
        "type": TYPE_INT,
        "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY
    })
    for i in _items.size():
        properties.append_array([{
            "name": "item_%d/text" % i,
            "type": TYPE_STRING
        },{
            "name": "item_%d/icon" % i,
            "class_name": &"Texture2D",
            "type": TYPE_OBJECT,
            "hint": PROPERTY_HINT_RESOURCE_TYPE,
            "hint_string": "Texture2D"
        }])

    properties.append_array([
        ThemePropertiesUtil.get_theme_override_group_property(),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_COLOR, &"font_color"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_COLOR, &"font_hover_color"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_COLOR, &"font_outline_color"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_CONSTANT, &"h_separation"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_CONSTANT, &"v_separation"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_CONSTANT, &"item_start_padding"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_CONSTANT, &"item_end_padding"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_CONSTANT, &"icon_max_width"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_CONSTANT, &"outline_size"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_FONT, &"font"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_FONT_SIZE, &"font_size"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_STYLEBOX, &"panel"
        ),
        ThemePropertiesUtil.get_theme_override_property_item(
            self, Theme.DATA_TYPE_STYLEBOX, &"hover"
        )
    ])

    return properties


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


func _update_size() -> void:
    # Find bounding rect (in screen coordinates).
    var bounding_window := _line_edit.get_last_exclusive_window()
    var bounding_rect: Rect2
    if bounding_window.is_embedded():
        bounding_rect = bounding_window.get_visible_rect()
    else:
        var screen := bounding_window.current_screen
        bounding_rect = DisplayServer.screen_get_usable_rect(screen)

    # Convert bounding rect to local space for later use
    var inverse_screen_transform := _line_edit.get_screen_transform().inverse()
    var local_bounding_rect := inverse_screen_transform * bounding_rect

    # Calculate ideal amount of items and the needed space
    var visible_items := mini(_candidates.size(), max_lines)
    var available_height := _cache.item_min_size.y * visible_items
    var base_rect := _line_edit.get_rect()

    # TODO: Look if more space over base rect or under it if auto.

    var popup_rect := Rect2(
        base_rect.position.x,
        base_rect.end.y,
        base_rect.size.x,
        _cache.panel_total_offset.y + available_height
    )

    # Keep inside bounding rect by reducing visible items
    if popup_rect.end.y > local_bounding_rect.end.y:
        var actual_available_height := (
            local_bounding_rect.end.y - popup_rect.position.y - _cache.panel_total_offset.y
        )
        visible_items = clampi(actual_available_height / _cache.item_min_size.y, 0, max_lines)
        available_height = _cache.item_min_size.y * visible_items
        popup_rect.size.y = _cache.panel_total_offset.y + available_height

    # Update cache and apply popup rect (in screen coordinates)
    var screen_transform := _line_edit.get_screen_transform()
    var screen_rect := screen_transform * popup_rect

    _cache.screen_rect = screen_rect
    _cache.visible_items = visible_items

    position = screen_rect.position
    size = screen_rect.size

    # Update basic rect cache
    var panel_rect := Rect2(Vector2.ZERO, popup_rect.size)
    _cache.panel_rect = panel_rect

    var content_rect := panel_rect
    content_rect.position += _cache.panel_start_offset
    content_rect.size -= _cache.panel_total_offset
    _cache.content_rect = content_rect

    # Update scroll bar
    var scroll_bar_rect := Rect2()
    _scroll_bar.visible = visible_items < _candidates.size()
    if _scroll_bar.visible:
        var scroll_min_size := _scroll_bar.get_combined_minimum_size()
        scroll_bar_rect = Rect2(
            content_rect.position.x,
            content_rect.position.y,
            scroll_min_size.x,
            content_rect.size.y
        )
        if not is_layout_rtl():
            scroll_bar_rect.position.x = content_rect.end.x - scroll_min_size.x

        _scroll_bar.position = scroll_bar_rect.position
        _scroll_bar.size = scroll_bar_rect.size
        _scroll_bar.max_value = _candidates.size()
        _scroll_bar.page = visible_items

    _cache.scroll_bar_rect = scroll_bar_rect

    # Update item rects
    var item_rect := content_rect
    item_rect.size.y = _cache.item_min_size.y
    if _scroll_bar.visible:
        var scroll_bar_rect_offset := scroll_bar_rect.size.x
        item_rect.size.x -= scroll_bar_rect_offset
        if is_layout_rtl():
            item_rect.position.x += scroll_bar_rect_offset
    _cache.item_rect = item_rect

    if is_layout_rtl():
        item_rect.position.x += _cache.item_end_padding
    else:
        item_rect.position.x += _cache.item_start_padding
    item_rect.size.x -= _cache.item_h_padding

    var icon_rect := item_rect
    icon_rect.size.x = ThemeDB.fallback_icon.get_width() * get_theme_default_base_scale()
    if _cache.icon_max_width > 0:
        icon_rect.size.x = _cache.icon_max_width
    if is_layout_rtl():
        icon_rect.position.x = item_rect.end.x - icon_rect.size.x
    _cache.icon_rect = icon_rect

    var icon_rect_offset := icon_rect.size.x + _cache.h_separation
    var text_rect := item_rect
    text_rect.size.x -= icon_rect_offset
    if not is_layout_rtl():
        text_rect.position.x += icon_rect_offset
    _cache.text_rect = text_rect


func _gained_focus() -> void:
    if not _line_edit.text.is_empty():
        _update_candidates(_line_edit.text)


func _update_candidates(text: String) -> void:
    _candidates.clear()
    _selected_candidate = -1
    _scroll_bar.value = 0
    if text.is_empty() or _is_submiting:
        hide()
        return

    for item in _items:
        item.priority = item.text.findn(text)
        if item.priority == -1: continue
        var idx := _candidates.bsearch_custom(item, _sort_items)
        _candidates.insert(idx, item)

    if _candidates.is_empty():
        hide()
    elif visible:
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


func _input(event: InputEvent) -> void:
    var mouse_event := event as InputEventMouse
    if not mouse_event:
        return

    var is_hovering := false
    var offset := _cache.item_rect.size.y
    var rect := _cache.item_rect

    var start_index := int(_scroll_bar.value)
    var end_index := start_index + _cache.visible_items
    for idx in range(start_index, end_index):
        if rect.has_point(mouse_event.position):
            is_hovering = true
            if _selected_candidate != idx:
                _selected_candidate = idx
                _panel.queue_redraw()
            break
        rect.position.y += offset

    var mouse_button_event := event as InputEventMouseButton
    if not mouse_button_event:
        return

    if is_hovering and _selected_candidate > -1 and mouse_button_event.button_index == MOUSE_BUTTON_LEFT and mouse_button_event.pressed:
        set_input_as_handled()
        _submit()

    var scroll_dir := 0.0
    if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
        scroll_dir -= 1.0
    if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
        scroll_dir += 1.0
    if scroll_dir != 0.0:
        _scroll_bar.value += scroll_dir # TODO: Find speed


func _gui_input(event: InputEvent) -> void:
    if not _line_edit.has_focus() or not visible or _candidates.is_empty():
        return

    var select_prev := &"ui_up"
    var select_next := &"ui_down"

    if event.is_action_pressed(select_prev, true) and _selected_candidate > -1:
        _select(-1)
        _line_edit.accept_event()

    if event.is_action_pressed(select_next, true):
        _select(1)
        _line_edit.accept_event()

    if event.is_action_pressed(&"ui_cancel"):
        hide()
        _line_edit.accept_event()

    if event.is_action_pressed(&"ui_accept") and _selected_candidate > -1:
        _line_edit.accept_event()
        _submit()


func _select(offset: int) -> void:
    _selected_candidate = wrapi(_selected_candidate + offset, 0, _candidates.size())
    var scroll_margin := _cache.visible_items - 1
    _scroll_bar.set_value_no_signal(clampi(
        _scroll_bar.value,
        maxi(0, _selected_candidate - scroll_margin),
        mini(_selected_candidate, _candidates.size())
    ))
    _panel.queue_redraw()


func _submit() -> void:
    _is_submiting = true
    var value := _candidates[_selected_candidate].text
    _line_edit.text = value
    _line_edit.caret_column = value.length()
    if select_all_on_submit:
        _line_edit.select_all()
    _line_edit.text_changed.emit(_line_edit.text)
    _is_submiting = false
    hide()


func _draw() -> void:
    var ci := _panel.get_canvas_item()
    _cache.panel.draw(ci, _cache.panel_rect)

    var item_rect := _cache.item_rect
    var icon_rect := _cache.icon_rect
    var text_rect := _cache.text_rect
    var rect_offset := _cache.item_rect.size.y

    var start_index := int(_scroll_bar.value)
    var end_index := start_index + _cache.visible_items
    for idx in range(start_index, end_index):
        var item := _candidates[idx]
        if idx == _selected_candidate:
            _cache.hover.draw(ci, item_rect)
        item_rect.position.y += rect_offset

        if item.text:
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
            if idx == _selected_candidate:
                color = _cache.font_hover_color
            text_line.draw(ci, position, color)
        text_rect.position.y += rect_offset

        if item.icon:
            var icon_size := item.icon.get_size()
            var scale_factor := minf(
                icon_rect.size.x / icon_size.x,
                icon_rect.size.y / icon_size.y
            )
            if scale_factor < 1.0:
                icon_size *= scale_factor
            var half_size := icon_size * 0.5
            var rect := Rect2(icon_rect.get_center() - half_size, icon_size)
            item.icon.draw_rect(ci, rect, false)
        icon_rect.position.y += rect_offset
