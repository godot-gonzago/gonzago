@tool
extends VBoxContainer

# TODO: Add button like in default Theme editor add popup.
#       LineEdit for type name. Base types as autocomplete?
#       Direct base type selection when adding.

const ThemeUtil := preload("../theme_util.gd")

signal theme_type_selected(theme_type: StringName)

@onready var _tree := get_node("Tree") as Tree

var _theme: Theme = null


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            if _theme:
                _build_tree()
        NOTIFICATION_THEME_CHANGED:
            if _theme and is_node_ready():
                _update_tree()


func inspect(theme: Theme) -> void:
    if _theme == theme: return
    _theme = theme
    if is_node_ready():
        _build_tree()


func _build_tree() -> void:
    _tree.clear()
    if not _theme: return
    
    var root := _tree.create_item()
    var types := ThemeUtil.get_type_list(_theme)
    _build_types_items(root, types)
    _update_tree()


func _build_types_items(parent: TreeItem, types: PackedStringArray) -> void:
    for type in types:
        var type_item := parent.create_child()
        type_item.set_text(0, type)
        type_item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
        var variations := ThemeUtil.get_type_variation_list(_theme, type)
        if variations.size() > 0:
            _build_types_items(type_item, variations)


func _update_tree() -> void:
    var root := _tree.get_root()
    _update_types_items(root)


func _update_types_items(parent: TreeItem) -> void:
    for item in parent.get_children():
        var type := item.get_text(0)
        var icon := ThemeUtil.get_theme_type_icon(type)
        item.set_icon(0, icon)
        
        var color := Color.WHITE
        if not ThemeUtil.has_type(_theme, type):
            color = color.darkened(0.5)
        item.set_custom_color(0, color)
        
        _update_types_items(item)


func _on_tree_item_selected() -> void:
    var item := _tree.get_selected()
    var type := item.get_text(0)
    theme_type_selected.emit(type)
