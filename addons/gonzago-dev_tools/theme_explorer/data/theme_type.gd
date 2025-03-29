@tool
extends RefCounted


const ThemeType := preload("./theme_type.gd")

var type := &""
var base_type := &""

var is_base_theme_type := false # From base theme
