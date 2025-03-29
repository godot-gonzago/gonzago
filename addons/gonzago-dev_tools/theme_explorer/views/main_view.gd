@tool
extends VBoxContainer

const FileBar := preload("./file_bar.gd")
const TypesTree := preload("./types_tree.gd")
const ItemsTree := preload("./items_tree.gd")

@onready var file_bar := get_node("FileBar") as FileBar
@onready var type_tree := get_node("Split/TypesTree") as TypesTree
@onready var items_tree := get_node("Split/Split/ItemsTree") as ItemsTree


var _theme: Theme


func _ready() -> void:
    _theme = file_bar.get_current_theme()
    type_tree.inspect(_theme)


func _on_theme_selected(theme: Theme) -> void:
    _theme = theme
    type_tree.inspect(_theme)
    items_tree.inspect(_theme, StringName())


func _on_types_tree_theme_type_selected(theme_type: StringName) -> void:
    items_tree.inspect(_theme, theme_type)
