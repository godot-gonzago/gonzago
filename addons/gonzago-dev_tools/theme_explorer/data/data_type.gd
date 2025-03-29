@tool
@static_unload
extends RefCounted


const DataType := preload("./data_type.gd")

static var DataTypeNone := DataType.new(-1)
static var DataTypeColor := DataType.new(
    Theme.DATA_TYPE_COLOR,
    &"Colors", &"colors", [&"color", &"colors"],
    &"Color", &"EditorIcons"
)
static var DataTypeConstant := DataType.new(
    Theme.DATA_TYPE_CONSTANT,
    &"Constants", &"constants", [&"constant", &"constants"],
    &"MemberConstant", &"EditorIcons"
)
static var DataTypeFont := DataType.new(
    Theme.DATA_TYPE_FONT,
    &"Fonts", &"font", [&"font", &"fonts"],
    &"FontItem", &"EditorIcons"
)
static var DataTypeFontSize := DataType.new(
    Theme.DATA_TYPE_FONT_SIZE,
    &"Font sizes", &"font_sizes", [&"font", &"fonts", &"size", &"sizes"],
    &"FontSize", &"EditorIcons"
)
static var DataTypeIcon := DataType.new(
    Theme.DATA_TYPE_ICON,
    &"Icons", &"icons", [&"icon", &"icons"],
    &"ImageTexture", &"EditorIcons"
)
static var DataTypeStylebox := DataType.new(
    Theme.DATA_TYPE_STYLEBOX,
    &"StyleBoxes", &"styles", [&"style", &"styles", &"box", &"boxes"],
    &"StyleBoxFlat", &"EditorIcons"
)

static var DataTypes: Dictionary[Theme.DataType, DataType] = {
    Theme.DATA_TYPE_COLOR: DataTypeColor,
    Theme.DATA_TYPE_CONSTANT: DataTypeColor,
    Theme.DATA_TYPE_FONT: DataTypeColor,
    Theme.DATA_TYPE_FONT_SIZE: DataTypeColor,
    Theme.DATA_TYPE_ICON: DataTypeColor,
    Theme.DATA_TYPE_STYLEBOX: DataTypeColor
}


static func _static_init() -> void:
    DataTypes.make_read_only()
    

static func get_by_data_type(data_type: Theme.DataType) -> DataType:
    if (DataTypes.has(data_type)):
        return DataTypes[data_type]
    return DataTypeNone


var _data_type: Theme.DataType
var _display_name: StringName
var _property_path: StringName
var _tags: Array[StringName]
var _icon_name: StringName
var _icon_type: StringName

var data_type: Theme.DataType: get = get_data_type
var display_name: StringName: get = get_display_name
var property_path: StringName: get = get_property_path
var tags: Array[StringName]: get = get_tags
var icon_name: StringName: get = get_icon_name
var icon_type: StringName: get = get_icon_type

func _init(
    data_type: Theme.DataType, display_name: StringName = &"",
    property_path: StringName = &"", tags: Array[StringName] = [],
    icon_name: StringName = &"", icon_type: StringName = &""
) -> void:
    _data_type = data_type
    _display_name = display_name
    _property_path = property_path
    _tags = tags
    _tags.make_read_only()
    _icon_name = icon_name
    _icon_type = icon_type
    
func get_data_type() -> Theme.DataType:
    return _data_type
    
func get_display_name() -> StringName:
    return _display_name
    
func get_property_path() -> StringName:
    return _property_path
    
func get_override_property_path() -> StringName:
    return StringName("theme_override_%s" % _property_path)
    
func get_tags() -> Array[StringName]:
    return _tags
    
func get_icon_name() -> StringName:
    return _icon_name
    
func get_icon_type() -> StringName:
    return _icon_type
