@tool
extends HBoxContainer

# https://docs.godotengine.org/en/stable/classes/class_editorresourcepicker.html
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.h
# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.cpp

signal resource_changed(resource: Resource)
signal resource_selected(resource: Resource, inspect: bool)

@export var base_type := ""
@export var editable := true
@export var toggle_mode := false

var edited_resource : Resource = null


func get_allowed_types() -> PackedStringArray:
    return []


func set_toggle_pressed(pressed: bool) -> void:
    pass
