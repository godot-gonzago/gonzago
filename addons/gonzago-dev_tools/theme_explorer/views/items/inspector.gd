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
@onready var _preview_texture := get_node("PreviewBox/PreviewTexture") as TextureRect
@onready var _meta_data := get_node("MetaData") as Tree
@onready var _meta_data_list := get_node("ScrollContainer/MetaDataList") as VBoxContainer

var _mode: Mode = Mode.NONE
var _theme: Theme = null
var _data_type: Theme.DataType = Theme.DATA_TYPE_MAX
var _theme_type: StringName = StringName()
var _theme_item: StringName = StringName()

var _color_picker := ColorPickerButton.new()
var _constant_spin_box := SpinBox.new()
var _font_resource_picker := EditorResourcePicker.new()
var _font_size_spin_box := SpinBox.new()
var _icon_resource_picker := EditorResourcePicker.new()
var _style_box_resource_picker := EditorResourcePicker.new()


func _init() -> void:
    _color_picker.visible = false
    _color_picker.text = "Color"
    _constant_spin_box.visible = false
    _constant_spin_box.rounded = true
    _constant_spin_box.min_value = 0.0
    _constant_spin_box.max_value = 128.0
    _constant_spin_box.allow_greater = true
    _font_resource_picker.visible = false
    _font_resource_picker.base_type = "Font"
    _font_size_spin_box.visible = false
    _font_size_spin_box.suffix = "pt"
    _font_size_spin_box.rounded = true
    _font_size_spin_box.min_value = 1.0
    _font_size_spin_box.max_value = 128.0
    _font_size_spin_box.allow_greater = true
    _icon_resource_picker.visible = false
    _icon_resource_picker.base_type = "Texture2D" # TODO: Disable unnecessairy display of icon with scaling
    _style_box_resource_picker.visible = false
    _style_box_resource_picker.base_type = "StyleBox"


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            if not NodeUtil.is_node_being_edited(self):
                _editor.add_child(_color_picker)
                _editor.add_child(_constant_spin_box)
                _editor.add_child(_font_resource_picker)
                _editor.add_child(_font_size_spin_box)
                _editor.add_child(_icon_resource_picker)
                _editor.add_child(_style_box_resource_picker)
                
                _meta_data
                
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
    
    _preview_box.visible = false
    _color_picker.visible = false
    _constant_spin_box.visible = false
    _font_resource_picker.visible = false
    _font_resource_picker.edited_resource = null
    _font_size_spin_box.visible = false
    _icon_resource_picker.visible = false
    _icon_resource_picker.edited_resource = null
    _style_box_resource_picker.visible = false
    _style_box_resource_picker.edited_resource = null
    
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
                #_queue_resource_preview()
                _update_theme_item_inspector()
    _build_meta_data()
    #_build_meta_data_list()


func _queue_resource_preview() -> void:
    if not Engine.is_editor_hint():
        return
    
    var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_item, _theme_type)
    if not value is Resource:
        return
    
    _preview_box.visible = true
    var resource_preview := EditorInterface.get_resource_previewer()
    resource_preview.queue_edited_resource_preview(
        value,
        self,
        "_on_resource_preview_ready",
        null
    )


func _on_resource_preview_ready(
    path: String,
    preview: Texture2D,
    thumbnail_preview: Texture2D,
    userdata: Variant
) -> void:
    _preview_texture.texture = preview
    

func _update_theme_item_inspector() -> void:
    var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_item, _theme_type)
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
            _constant_spin_box.visible = true
            _constant_spin_box.value = constant
            _constant_spin_box.suffix = suffix
        Theme.DATA_TYPE_FONT:
            var font: Font = value as Font
            _font_resource_picker.visible = true
            _font_resource_picker.edited_resource = font
        Theme.DATA_TYPE_FONT_SIZE:
            var font_size: int = value as int
            _font_size_spin_box.visible = true
            _font_size_spin_box.value = font_size
        Theme.DATA_TYPE_ICON:
            var icon: Texture2D = value as Texture2D
            _icon_resource_picker.visible = true
            _icon_resource_picker.edited_resource = icon
        Theme.DATA_TYPE_STYLEBOX:
            var style_box: StyleBox = value as StyleBox
            _style_box_resource_picker.visible = true
            _style_box_resource_picker.edited_resource = style_box
            
    
func _draw_preview() -> void:
    var canvas_item := _preview.get_canvas_item()
    var canvas_item_rect := Rect2(Vector2.ZERO, _preview.size)
    var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_item, _theme_type)
    
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
                font_size = ThemeUtil.get_pairing_font_size(_theme, _theme_item, _theme_type)
            elif _data_type == Theme.DATA_TYPE_FONT_SIZE:
                font = ThemeUtil.get_pairing_font(_theme, _theme_item, _theme_type)
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

func _build_meta_data() -> void:
    _meta_data.clear()
    var root := _meta_data.create_item()
    
    match _mode:
        Mode.THEME:
            var is_built_in := ThemeUtil.is_built_in_theme(_theme)
            _add_checked_value_meta_child(root, "Is Built In", is_built_in)
            var has_base_theme := ThemeUtil.has_base_theme(_theme)
            _add_checked_value_meta_child(root, "Has Base Theme", has_base_theme)
            
            var has_default_base_scale := ThemeUtil.has_default_base_scale(_theme)
            _add_checked_value_meta_child(root, "Has Default Base Scale", has_default_base_scale)
            var default_base_scale := ThemeUtil.get_default_base_scale(_theme, true)
            _add_ranged_value_meta_child(root, "Default Base Scale", default_base_scale)
            var has_default_font := ThemeUtil.has_default_font(_theme)
            _add_checked_value_meta_child(root, "Has Default Font", has_default_font)
            #var default_font := ThemeUtil.get_default_font(_theme)
            var has_default_font_size := ThemeUtil.has_default_font_size(_theme)
            _add_checked_value_meta_child(root, "Has Default Font Size", has_default_font_size)
            var default_font_size := ThemeUtil.get_default_font_size(_theme, true)
            _add_ranged_value_meta_child(root, "Default Font Size", default_font_size)
        Mode.THEME_TYPE:
            _add_string_value_meta_child(
                root, "Name", _theme_type,
                ThemeUtil.get_theme_type_icon(_theme_type),
            )
            _add_checked_value_meta_child(
                root, "Is Built-In Type",
                ThemeUtil.is_built_in_type(_theme_type)
            )
            _add_checked_value_meta_child(
                root, "Is Default",
                not ThemeUtil.has_type(_theme, _theme_type)
            )
            
            var variation_base := _theme.get_type_variation_base(_theme_type)
            var is_variation := not variation_base.is_empty()
            _add_checked_value_meta_child(
                root, "Is Variation", is_variation)
            if is_variation:
                _add_string_value_meta_child(
                    root,
                    "Variation Base",
                    variation_base,
                    ThemeUtil.get_theme_type_icon(variation_base)
                )
            
            for data_type in Theme.DATA_TYPE_MAX:
                var data_type_name := ThemeUtil.get_data_type_name(data_type)
                var total_items := ThemeUtil.get_theme_item_list(_theme, data_type, _theme_type, true, false)
                var items := ThemeUtil.get_theme_item_list(_theme, data_type, _theme_type, false, false)
                
                var total_count := total_items.size()
                var items_count := items.size()
                var defaults_count := total_count - items_count
                
                var total_item := _add_string_value_meta_child(
                    root,
                    "Total %s" % data_type_name,
                    str(total_count)
                )
                _add_string_value_meta_child(total_item, "Default %s" % data_type_name, str(defaults_count))
                _add_string_value_meta_child(total_item, data_type_name, str(items_count))
        Mode.DATA_TYPE:
            var total_items := ThemeUtil.get_theme_item_list(_theme, _data_type, _theme_type, true, false)
            var items := ThemeUtil.get_theme_item_list(_theme, _data_type, _theme_type, false, false)
            
            var total_count := total_items.size()
            var items_count := items.size()
            var defaults_count := total_count - items_count
            
            _add_string_value_meta_child(root, "Total Items", str(total_count))
            _add_string_value_meta_child(root, "Default Items", str(defaults_count))
            _add_string_value_meta_child(root, "Items", str(items_count))
        Mode.THEME_ITEM:
            var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_item, _theme_type)
            _add_string_value_meta_child(
                root, "Name", _theme_item,
            )
            _add_checked_value_meta_child(
                root, "Is Default",
                not ThemeUtil.has_theme_item(_theme, _data_type, _theme_item, _theme_type)
            )
            
            match _data_type:
                Theme.DATA_TYPE_COLOR:
                    var color: Color = value as Color
                    _add_string_value_meta_child(root, "HTML", color.to_html())
                Theme.DATA_TYPE_CONSTANT:
                    var constant: int = value as int
                Theme.DATA_TYPE_FONT:
                    var font: Font = value as Font
                    _add_string_value_meta_child(
                        root,
                        "Type",
                         font.get_class() if font else "None"
                    )
                    _add_string_value_meta_child(root, "Path", font.resource_path)
                    
                    var has_pairing_font_size := ThemeUtil.has_pairing_font_size(_theme, _theme_item, _theme_type)
                    _add_checked_value_meta_child(root, "Has Pairing Font Size", has_pairing_font_size)
                    if has_pairing_font_size:
                        var pairing_font_size_name = ThemeUtil.get_pairing_font_size_name(_theme_item)
                        _add_string_value_meta_child(root, "Pairing Font Size Name", pairing_font_size_name)
                Theme.DATA_TYPE_FONT_SIZE:
                    var font_size: int = value as int
                    var has_pairing_font := ThemeUtil.has_pairing_font(_theme, _theme_item, _theme_type)
                    _add_checked_value_meta_child(root, "Has Pairing Font", has_pairing_font)
                    if has_pairing_font:
                        var pairing_font_name = ThemeUtil.get_pairing_font_name(_theme_item)
                        _add_string_value_meta_child(root, "Pairing Font Name", pairing_font_name)
                Theme.DATA_TYPE_ICON:
                    var icon: Texture2D = value as Texture2D
                    _add_string_value_meta_child(
                        root,
                        "Type",
                         icon.get_class() if icon else "None"
                    )
                    _add_string_value_meta_child(root, "Path", icon.resource_path)
                    
                    if icon:
                        _add_string_value_meta_child(root, "Size", str(icon.get_size()))
                        _add_string_value_meta_child(root, "Width", str(icon.get_width()))
                        _add_string_value_meta_child(root, "Height", str(icon.get_height()))
                        _add_checked_value_meta_child(root, "Has Alpha", icon.has_alpha())
                    if icon is ImageTexture:
                        _add_string_value_meta_child(root, "Format", str(icon.get_format())) # TODO:
                Theme.DATA_TYPE_STYLEBOX:
                    var style_box: StyleBox = value as StyleBox
                    _add_string_value_meta_child(
                        root,
                        "Type",
                        style_box.get_class() if style_box else "None"
                    )
                    _add_string_value_meta_child(root, "Path", style_box.resource_path)
                    
                    # float get_content_margin(margin: Side)
                    # float get_margin(margin: Side)
                    # Vector2 get_minimum_size()
                    if style_box is StyleBoxFlat:
                        pass # TODO
                    if style_box is StyleBoxLine:
                        pass # TODO
                    if style_box is StyleBoxTexture:
                        pass # TODO


func _add_labeled_meta_child(root: TreeItem, label: String) -> TreeItem:
    var item := root.create_child()
    item.set_text(0, label)
    return item
    

func _add_string_value_meta_child(
    root: TreeItem,
    label: String,
    value: String,
    icon: Texture2D = null
) -> TreeItem:
    var item := _add_labeled_meta_child(root, label)
    item.set_text(1, value)
    if item:
        item.set_icon(1, icon)
    return item


func _add_ranged_value_meta_child(
    root: TreeItem,
    label: String,
    value: float,
    min := 0.0,
    max := 100.0,
    step := 1.0,
    expr := false
) -> TreeItem:
    var item := _add_labeled_meta_child(root, label)
    item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
    item.set_range_config(1, min, max, step, expr)
    item.set_range(1, value)
    return item


func _add_checked_value_meta_child(root: TreeItem, label: String, value: bool) -> TreeItem:
    var item := _add_labeled_meta_child(root, label)
    item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
    item.set_text(1, "Yes" if value else "No")
    item.set_checked(1, value)
    return item


func _build_meta_data_list() -> void:
    for child in _meta_data_list.get_children():
        child.queue_free()
        
    if not Engine.is_editor_hint():
        return
        
    var inspector := EditorInterface.get_inspector()
        
    match _mode:
        Mode.THEME:
            for property in _theme.get_property_list():
                var usage: PropertyUsageFlags = property.get("usage", PROPERTY_USAGE_NONE)
                if (usage & PROPERTY_USAGE_EDITOR) != PROPERTY_USAGE_EDITOR:
                    continue
                
                var property_name: String = property.get("name", "")
                if not property_name in ["default_base_scale", "default_font", "default_font_size"]:
                    continue
                
                var cls_name: StringName = property.get("class_name", &"")
                var type: Variant.Type = property.get("type", TYPE_NIL)
                var hint: PropertyHint = property.get("hint", PROPERTY_HINT_NONE)
                var hint_string: String = property.get("hint_string", "")
                
                var editor := inspector.instantiate_property_editor(
                    _theme, type, property_name, hint, hint_string, usage,
                    false
                )
                editor.label = property_name.capitalize()
                #editor.read_only = true
                add_child(editor)
        Mode.THEME_TYPE:
            pass
        Mode.DATA_TYPE:
            pass
        Mode.THEME_ITEM:
            var value := ThemeUtil.get_theme_item(_theme, _data_type, _theme_item, _theme_type)
            
            match _data_type:
                Theme.DATA_TYPE_COLOR:
                    var color: Color = value as Color
                Theme.DATA_TYPE_CONSTANT:
                    var constant: int = value as int
                Theme.DATA_TYPE_FONT:
                    var font: Font = value as Font
                Theme.DATA_TYPE_FONT_SIZE:
                    var font_size: int = value as int
                Theme.DATA_TYPE_ICON:
                    var icon: Texture2D = value as Texture2D
                Theme.DATA_TYPE_STYLEBOX:
                    var style_box: StyleBox = value as StyleBox
                    
                    if style_box is StyleBoxFlat:
                        pass # TODO
                    if style_box is StyleBoxLine:
                        pass # TODO
                    if style_box is StyleBoxTexture:
                        pass # TODO
