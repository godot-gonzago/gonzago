@tool
extends Control


var _file_bar: FileBar


func _init() -> void:
    _file_bar = FileBar.new()
    _file_bar.set_anchors_and_offsets_preset(
        Control.PRESET_TOP_WIDE
    )
    add_child(_file_bar)


func _get_minimum_size() -> Vector2:
    return Vector2(640, 480)


class Filter extends LineEdit:
    func _init() -> void:
        clear_button_enabled = true
        select_all_on_focus = true

    func _notification(what: int) -> void:
        match what:
            NOTIFICATION_READY, NOTIFICATION_TRANSLATION_CHANGED:
                placeholder_text = tr("Filter...")
            NOTIFICATION_THEME_CHANGED:
                right_icon = get_theme_icon(&"Search", &"EditorIcons")


class FileBar extends Control:
    var _bg: StyleBox
    var _separation: int
    var _tabs: TabBar
    var _open_button: Button

    func _init() -> void:
        _tabs = TabBar.new()
        _tabs.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
        _tabs.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
        _tabs.add_tab("Editor")
        _tabs.add_tab("Default")
        add_child(_tabs)

        _open_button = Button.new()
        _open_button.flat = true
        _open_button.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
        add_child(_open_button)

    func _notification(what: int) -> void:
        match what:
            NOTIFICATION_READY:
                pass
            NOTIFICATION_THEME_CHANGED:
                var internal_theme_icon := get_theme_icon("GuiVisibilityXray", "EditorIcons")
                var theme_resource_icon := get_theme_icon("Theme", "EditorIcons")
                var missing_theme_icon := get_theme_icon("MissingResource", "EditorIcons")

                var editor_theme := EditorInterface.get_editor_theme()
                _tabs.set_tab_icon(0, internal_theme_icon if editor_theme else missing_theme_icon)
                var default_theme := ThemeDB.get_default_theme()
                _tabs.set_tab_icon(1, internal_theme_icon if default_theme else missing_theme_icon)

                #var close_icon := get_theme_icon("close", "TabBar")
                #_tabs.set_tab_button_icon(0, close_icon)
                #_tabs.set_tab_button_icon(1, close_icon)

                _bg = get_theme_stylebox("tabbar_background", "TabContainer")
                _separation = get_theme_constant("separation", "HBoxContainer")
                _open_button.icon = get_theme_icon("Load", "EditorIcons")
                _open_button.add_theme_color_override(
                    "icon_normal_color",
                    get_theme_color("font_unselected_color", "TabBar")
                )
                call_deferred("_update_layout")
            NOTIFICATION_DRAW:
                var rect := Rect2(Vector2.ZERO, size)
                draw_style_box(_bg, rect)

    func _update_layout() -> void:
        _open_button.set_offset(SIDE_TOP, _bg.get_margin(SIDE_TOP))
        _open_button.set_offset(SIDE_BOTTOM, -_bg.get_margin(SIDE_BOTTOM))
        _open_button.set_offset(SIDE_LEFT, -(_bg.get_margin(SIDE_LEFT) + _open_button.size.x))
        _open_button.set_offset(SIDE_RIGHT, -_bg.get_margin(SIDE_RIGHT))

        _tabs.set_offset(SIDE_TOP, -(_bg.get_margin(SIDE_TOP) + _tabs.size.y))
        _tabs.set_offset(SIDE_BOTTOM, -_bg.get_margin(SIDE_BOTTOM))
        _tabs.set_offset(SIDE_LEFT, _bg.get_margin(SIDE_LEFT))
        _tabs.set_offset(SIDE_RIGHT, -(_bg.get_margin(SIDE_RIGHT) + _open_button.size.x + _separation))

    func _get_minimum_size() -> Vector2:
        var min_size := _tabs.get_combined_minimum_size()
        min_size.x += _separation
        var open_button_min_size := _open_button.get_combined_minimum_size()
        min_size.x += open_button_min_size.x
        min_size.y = maxf(min_size.y, open_button_min_size.y)
        if _bg:
            min_size += _bg.get_minimum_size()
        return min_size
