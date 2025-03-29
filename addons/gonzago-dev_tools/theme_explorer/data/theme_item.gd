@tool
extends RefCounted

var theme: Theme

var data_type: Theme.DataType
var theme_type: StringName
var name: StringName

var is_base_theme_item := false # From base theme (override)
