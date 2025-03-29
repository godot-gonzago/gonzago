@tool
extends VBoxContainer

const FileBar := preload("./file_bar.gd")
const TypesTree := preload("./types_tree.gd")

@onready var file_bar := get_node("FileBar") as FileBar
@onready var type_tree := get_node("Split/TypesTree") as TypesTree


func _ready() -> void:
    var theme := file_bar.get_current_theme()
    type_tree.inspect(theme)


func _on_theme_selected(theme: Theme) -> void:
    print("Theme selected")
    type_tree.inspect(theme)
