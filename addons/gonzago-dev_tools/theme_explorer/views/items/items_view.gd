@tool
extends HSplitContainer


const NodeUtil := Gonzago.NodeUtil
const TypesTree := preload("./types_tree.gd")
const ItemsTree := preload("./items_tree.gd")
const Inspector := preload("./inspector.gd")

@onready var type_tree := get_node("TypesTree") as TypesTree
@onready var items_tree := get_node("Split/ItemsTree") as ItemsTree
@onready var inspector := get_node("Split/Inspector") as Inspector

var _theme: Theme


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            if NodeUtil.is_node_being_edited(self):
                return
            if _theme:
                type_tree.inspect(_theme)
                items_tree.inspect(_theme, StringName())
                inspector.inspect_theme(_theme)


func inspect(theme: Theme) -> void:
    _theme = theme
    if is_node_ready():
        type_tree.inspect(_theme)
        items_tree.inspect(_theme, StringName())
        inspector.inspect_theme(_theme)


func _on_types_tree_theme_type_selected(theme_type: StringName) -> void:
    items_tree.inspect(_theme, theme_type)
    inspector.inspect_theme_type(_theme, theme_type)


func _on_items_tree_data_type_selected(
    data_type: Theme.DataType,
    theme_type: StringName
) -> void:
    inspector.inspect_data_type(_theme, data_type, theme_type)


func _on_items_tree_theme_item_selected(
    data_type: Theme.DataType,
    theme_type: StringName,
    theme_item: StringName
) -> void:
    inspector.inspect_theme_item(_theme, data_type, theme_type, theme_item)
