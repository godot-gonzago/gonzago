@tool
extends VBoxContainer

# TODO: Add button like in default Theme editor add popup.
#       LineEdit for type name. Base types as autocomplete?
#       https://github.com/Lenrow/line-edit-complete-godot
#       Direct base type selection when adding.

const ThemeUtil := preload("../../theme_util.gd")
const EditorThemeUtil := preload("../../editor_theme_util.gd")

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
    _is_read_only = ThemeUtil.is_read_only(_theme)
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
        var type_item := parent.create_child()
        type_item.set_text(0, type)
        type_item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
        if not _is_read_only:
            type_item.add_button(0, ThemeDB.fallback_icon, 0)
        var variations := ThemeUtil.get_type_variation_list(_theme, type)
        if variations.size() > 0:
            _build_types_items(type_item, variations)


func _update_tree() -> void:
    var root := _tree.get_root()
    _update_types_items(root)


func _update_types_items(parent: TreeItem) -> void:
    for item in parent.get_children():
        var type := item.get_text(0)
        var icon := EditorThemeUtil.get_theme_type_icon(type)
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
        
        _update_types_items(item)


func _on_tree_item_selected() -> void:
    var item := _tree.get_selected()
    var type := item.get_text(0)
    theme_type_selected.emit(type)


func _on_filter_text_changed(new_text: String) -> void:
    var root := _tree.get_root()
    _filter_types_items(root, new_text)
    
func _filter_types_items(parent: TreeItem, filter: String) -> bool:
    var has_visible_children := false
    for item in parent.get_children():
        if _filter_types_items(item, filter):
            item.visible = true
            has_visible_children = true
            continue
        
        var type := item.get_text(0)
        if not filter or type.containsn(filter):
            item.visible = true
            has_visible_children = true
            continue
        
        item.visible = false
    return has_visible_children


func _on_tree_item_activated() -> void:
    var item := _tree.get_selected()
    var type := item.get_text(0)
    var is_default := not ThemeUtil.has_type(_theme, type)
    item.set_editable(0, not is_default) # TODO: On gui input, F2 or double click


func _on_tree_item_edited() -> void:
    var item := _tree.get_edited()
    push_warning("Hello!")
    pass


func _on_tree_button_clicked(
    item: TreeItem,
    column: int,
    id: int,
    mouse_button_index: int
 ) -> void:
    var type := item.get_text(0)
    var is_default := not ThemeUtil.has_type(_theme, type)
    pass
