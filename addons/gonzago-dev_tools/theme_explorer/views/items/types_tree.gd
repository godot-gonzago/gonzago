@tool
extends VBoxContainer

# TODO: Add button like in default Theme editor add popup.
#       LineEdit for type name. Base types as autocomplete?
#       https://github.com/Lenrow/line-edit-complete-godot
#       Direct base type selection when adding.

const ThemeUtil := Gonzago.ThemeUtil

signal theme_type_selected(theme_type: StringName)

@onready var _add_button := get_node("Toolbar/AddButton") as Button
@onready var _tree := get_node("Tree") as Tree

var _theme: Theme = null
var _is_read_only: bool = true

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
    _is_read_only = ThemeUtil.is_built_in_theme(_theme)
    if is_node_ready():
        _build_tree()


func _build_tree() -> void:
    _add_button.visible = not _is_read_only

    _tree.clear()
    if not _theme: return

    var root := _tree.create_item()
    var types := ThemeUtil.get_type_list(_theme)
    _build_types_items(root, types)
    _update_tree()


func _build_types_items(parent: TreeItem, types: PackedStringArray) -> void:
    for type in types:
        var item := parent.create_child()
        _build_type_item(item, type)
        var variations := ThemeUtil.get_type_variation_list(_theme, type)
        if variations.size() > 0:
            _build_types_items(item, variations)


func _build_type_item(item: TreeItem, type: StringName) -> void:
    item.set_metadata(0, type)
    item.set_text(0, type)
    item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
    if not _is_read_only:
        item.add_button(0, ThemeDB.fallback_icon, 0)


func _update_tree() -> void:
    var root := _tree.get_root()
    _update_types_items(root)


func _update_types_items(parent: TreeItem) -> void:
    for item in parent.get_children():
        _update_type_item(item)
        _update_types_items(item)


func _update_type_item(item: TreeItem) -> void:
    var type := item.get_metadata(0) as StringName
    var icon := ThemeUtil.get_theme_type_icon(type)
    item.set_icon(0, icon)

    var is_default := not ThemeUtil.has_type(_theme, type)
    var color := get_theme_color(&"font_color", &"Tree")
    if is_default:
        color = get_theme_color(&"font_disabled_color", &"Tree")
    item.set_custom_color(0, color)

    if not _is_read_only:
        if is_default:
            item.set_button(0, 0, get_theme_icon(&"Add", &"EditorIcons"))
        else:
            item.set_button(0, 0, get_theme_icon(&"Remove", &"EditorIcons"))


func _on_tree_item_selected() -> void:
    var item := _tree.get_selected()
    var type := item.get_metadata(0) as StringName
    theme_type_selected.emit(type)


func _on_filters_changed(filters: PackedStringArray) -> void:
    var root := _tree.get_root()
    _filter_types_items(root, filters)


func _filter_types_items(parent: TreeItem, filters: PackedStringArray) -> bool:
    var has_visible_children := false
    for item in parent.get_children():
        if _filter_types_items(item, filters):
            has_visible_children = true
    
    if has_visible_children:
        parent.visible = true
        return true
    
    if filters.is_empty():
        parent.visible = true
        return true
            
    var type := parent.get_text(0)
    for filter in filters:
        if type.containsn(filter):
            parent.visible = true
            return true
            
    parent.visible = false
    return false


func _on_tree_item_activated() -> void:
    var item := _tree.get_selected()
    var type := item.get_metadata(0) as StringName
    var is_default := not ThemeUtil.has_type(_theme, type)
    if not _is_read_only and not is_default:
        _tree.edit_selected(true)
        # TODO: On gui input, F2 or double click


func _on_tree_item_edited() -> void:
    var item := _tree.get_edited()
    var type := item.get_metadata(0) as StringName
    push_warning("Hello!")


func _on_tree_button_clicked(
    item: TreeItem,
    column: int,
    id: int,
    mouse_button_index: int
) -> void:
    var type := item.get_metadata(0) as StringName
    var is_default := not ThemeUtil.has_type(_theme, type)
    pass
