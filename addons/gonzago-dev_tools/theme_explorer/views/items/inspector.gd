@tool
extends VBoxContainer


enum Mode {
    NONE = -1,
    THEME = 0,
    THEME_TYPE = 1,
    DATA_TYPE = 2,
    THEME_ITEM = 3
}

const NodeUtil := Gonzago.NodeUtil
const ThemeUtil := Gonzago.ThemeUtil

@onready var _hierarchy_button := get_node("Header/HierarchyButton") as OptionButton
@onready var _editor := get_node("Editor") as Control
@onready var _preview_box := get_node("PreviewBox") as PanelContainer
@onready var _preview := get_node("PreviewBox/Preview") as Control

var _mode: Mode = Mode.NONE
var _theme: Theme = null
var _data_type: Theme.DataType = Theme.DATA_TYPE_MAX
var _theme_type: StringName = StringName()
var _theme_item: StringName = StringName()

var _color_picker := ColorPickerButton.new()
var _spin_box := SpinBox.new()
var _resource_picker := EditorResourcePicker.new()


func _init() -> void:
    _color_picker.visible = false
    _color_picker.text = "Color"
    _spin_box.visible = false
    _spin_box.rounded = true
    _spin_box.min_value = 0.0
    _spin_box.max_value = 100.0
    _spin_box.allow_greater = true
    _resource_picker.visible = false


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            if not NodeUtil.is_node_being_edited(self):
                _editor.add_child(_color_picker)
                _editor.add_child(_spin_box)
                _editor.add_child(_resource_picker)
                
                _preview.draw.connect(_draw_preview)
                _update_inspector()


func inspect_theme(theme: Theme) -> void:
    _mode = Mode.THEME if theme else Mode.NONE
    _theme = theme
    if is_node_ready():
        _update_inspector()


func inspect_theme_type(theme: Theme, theme_type: StringName) -> void:
    _mode = Mode.THEME_TYPE
    _theme = theme
    _theme_type = theme_type
    if is_node_ready():
        _update_inspector()


func inspect_data_type(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName
) -> void:
    _mode = Mode.DATA_TYPE
    _theme = theme
    _data_type = data_type
    _theme_type = theme_type
    if is_node_ready():
        _update_inspector()


func inspect_theme_item(
    theme: Theme,
    data_type: Theme.DataType,
    theme_type: StringName,
    theme_item :StringName
) -> void:
    _mode = Mode.THEME_ITEM
    _theme = theme
    _data_type = data_type
    _theme_type = theme_type
    _theme_item = theme_item
    if is_node_ready():
        _update_inspector()


func _update_inspector() -> void:
    _hierarchy_button.clear()
    
    _color_picker.visible = false
    _spin_box.visible = false
    _resource_picker.visible = false
    _resource_picker.edited_resource = null
    _resource_picker.base_type = ""
    _preview_box.visible = false
    
    for mode in range(_mode, -1, -1):
        var idx := _hierarchy_button.item_count
        _hierarchy_button.add_item("")
        _hierarchy_button.set_item_metadata(idx, mode)
        
        match mode:
            Mode.THEME:
                var icon := ThemeUtil.get_theme_icon(_theme)
                var text := ThemeUtil.get_theme_name(_theme)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, text)
            Mode.THEME_TYPE:
                var icon := ThemeUtil.get_theme_type_icon(_theme_type)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, _theme_type)
            Mode.DATA_TYPE:
                var icon := ThemeUtil.get_data_type_icon(_data_type)
                var text := ThemeUtil.get_data_type_name(_data_type)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, text)
            Mode.THEME_ITEM:
                var icon := ThemeUtil.get_data_type_icon(_data_type)
                _hierarchy_button.set_item_icon(idx, icon)
                _hierarchy_button.set_item_text(idx, _theme_item)
                _preview_box.visible = true
                _preview.queue_redraw()
                _update_theme_item_inspector()
                
                
func _update_theme_item_inspector() -> void:
    var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_type, _theme_item)
    # TODO: Handle editable
    match _data_type:
        Theme.DATA_TYPE_COLOR:
            var color: Color = value as Color
            _color_picker.visible = true
            _color_picker.color = color
        Theme.DATA_TYPE_CONSTANT:
            var constant: int = value as int
            var constant_type := ThemeUtil.get_constant_type(_theme_item)
            var suffix := ThemeUtil.get_constant_type_suffix(constant_type)
            _spin_box.visible = true
            _spin_box.value = constant
            _spin_box.suffix = suffix
        Theme.DATA_TYPE_FONT:
            var font: Font = value as Font
            _resource_picker.visible = true
            _resource_picker.base_type = "Font"
            _resource_picker.edited_resource = font
        Theme.DATA_TYPE_FONT_SIZE:
            var font_size: int = value as int
            _spin_box.visible = true
            _spin_box.value = font_size
            _spin_box.suffix = "pt"
        Theme.DATA_TYPE_ICON:
            var icon: Texture2D = value as Texture2D
            _resource_picker.visible = true
            _resource_picker.base_type = "Texture2D"
            _resource_picker.edited_resource = icon
        Theme.DATA_TYPE_STYLEBOX:
            var style_box: StyleBox = value as StyleBox
            _resource_picker.visible = true
            _resource_picker.base_type = "StyleBox"
            _resource_picker.edited_resource = style_box
            
    
func _draw_preview() -> void:
    var canvas_item := _preview.get_canvas_item()
    var canvas_item_rect := Rect2(Vector2.ZERO, _preview.size)
    var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_type, _theme_item)
    
    # TODO: Externalize into draw util or something
    match _data_type:
        Theme.DATA_TYPE_COLOR:
            var color: Color = value as Color
            RenderingServer.canvas_item_add_rect(
                canvas_item,
                canvas_item_rect,
                color
            )
        Theme.DATA_TYPE_CONSTANT:
            var constant: int = value as int
            var constant_type := ThemeUtil.get_constant_type(_theme_item)
            var suffix := ThemeUtil.get_constant_type_suffix(constant_type)
            var text := str(constant)
            if suffix:
                text += " " + suffix
            if constant_type == ThemeUtil.ConstantType.FLAG:
                text += " (%s)" % ["true" if constant > 0 else "false"]
            var font := get_theme_default_font()
            var font_size := get_theme_default_font_size()
            var pos: Vector2 = canvas_item_rect.position
            pos.y += font.get_ascent(font_size)
            font.draw_string(
                canvas_item,
                pos,
                text,
                HORIZONTAL_ALIGNMENT_LEFT,
                canvas_item_rect.size.x,
                font_size,
                Color.WHITE,
                TextServer.JUSTIFICATION_CONSTRAIN_ELLIPSIS
            )
        Theme.DATA_TYPE_FONT, Theme.DATA_TYPE_FONT_SIZE:
            var font: Font
            var font_size: int
            if _data_type == Theme.DATA_TYPE_FONT:
                font = value as Font
                font_size = ThemeUtil.get_pairing_font_size(_theme, _theme_type, _theme_item)
            elif _data_type == Theme.DATA_TYPE_FONT_SIZE:
                font = ThemeUtil.get_pairing_font(_theme, _theme_type, _theme_item)
                font_size = value as int
            var pos: Vector2 = canvas_item_rect.position
            pos.y += font.get_ascent(font_size)
            #font.get_multiline_string_size()
            var line_height := font.get_height(font_size)
            var height := canvas_item_rect.size.y - font.get_descent(font_size)
            var max_lines := ceili(height / line_height)
            font.draw_multiline_string(
                canvas_item,
                pos,
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                HORIZONTAL_ALIGNMENT_LEFT,
                canvas_item_rect.size.x,
                font_size,
                max_lines,
                Color.WHITE,
                TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE,
                TextServer.JUSTIFICATION_CONSTRAIN_ELLIPSIS
            )
        Theme.DATA_TYPE_ICON:
            var icon: Texture2D = value as Texture2D
            var icon_size := icon.get_size()
            var scale_factor := minf(
                canvas_item_rect.size.x / icon_size.x,
                canvas_item_rect.size.y / icon_size.y
            )
            if scale_factor < 1.0:
                icon_size *= scale_factor
            var half_size := icon_size * 0.5
            var rect := Rect2(
                canvas_item_rect.get_center() - half_size,
                icon_size
            )
            RenderingServer.canvas_item_add_texture_rect(
                canvas_item,
                rect,
                icon.get_rid()
            )
        Theme.DATA_TYPE_STYLEBOX:
            var style_box: StyleBox = value as StyleBox
            #var rect := canvas_item_rect.grow_individual(
                #-style_box.get_margin(SIDE_LEFT),
                #-style_box.get_margin(SIDE_TOP),
                #-style_box.get_margin(SIDE_RIGHT),
                #-style_box.get_margin(SIDE_BOTTOM)
            #)
            style_box.draw(canvas_item, canvas_item_rect)
