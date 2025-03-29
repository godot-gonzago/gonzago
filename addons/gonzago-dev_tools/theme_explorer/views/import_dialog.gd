@tool
extends AcceptDialog

const ThemeUtil := preload("../theme_util.gd")
const FileBar := preload("./file_bar.gd")

@onready var _file_bar := get_node("ImportTree/FileBar") as FileBar
@onready var _tree := get_node("ImportTree/Tree") as Tree

var _theme: Theme = null


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            _tree.set_column_expand(0, true)
            _tree.set_column_expand(1, false)
            _tree.set_column_title(1, tr("Import"))
            _tree.set_column_expand(2, false)
            _tree.set_column_title(2, tr("With Data"))
            
            if not _theme:
                _theme = _file_bar.get_current_theme()
            if _theme:
                _build_tree()
        NOTIFICATION_THEME_CHANGED:
            if _theme and is_node_ready():
                _update_tree()

    
func _build_tree() -> void:
    _tree.clear()
    if not _theme: return
    
    var root := _tree.create_item()
    var types := ThemeUtil.get_type_list(_theme, true, false)
    for type in types:
        var type_item := root.create_child()
        type_item.set_text(0, type)
        type_item.set_text_overrun_behavior(0, TextServer.OVERRUN_TRIM_ELLIPSIS)
        type_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
        type_item.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
        type_item.collapsed = true
        
        for data_type in Theme.DATA_TYPE_MAX:
            var theme_items := ThemeUtil.get_theme_item_list(
                _theme, data_type, type, false, false
            )
            if theme_items.size() == 0:
                continue
            
            var data_type_root := type_item.create_child()
            data_type_root.set_text(0, ThemeUtil.get_data_type_name(data_type))
            data_type_root.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
            data_type_root.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
            data_type_root.set_metadata(0, data_type)
            data_type_root.collapsed = true
                
            for theme_item in theme_items:
                var theme_tree_item := data_type_root.create_child()
                theme_tree_item.set_text(0, theme_item)
                theme_tree_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
                theme_tree_item.set_cell_mode(2, TreeItem.CELL_MODE_CHECK)
    
    _update_tree()


func _update_tree() -> void:
    var root := _tree.get_root()
    for item in root.get_children():
        var type := item.get_text(0)
        var icon := ThemeUtil.get_theme_type_icon(type)
        item.set_icon(0, icon)
        
        for data_type_item in item.get_children():
            var data_type: int = data_type_item.get_metadata(0)
            data_type_item.set_icon(0, ThemeUtil.get_data_type_icon(data_type))

# TODO: data_type_item.propagate_check(1)
# TODO: theme_tree_item.set_indeterminate(1, true)

func _on_file_bar_theme_selected(theme: Theme) -> void:
    if _theme == theme: return
    _theme = theme
    if is_node_ready():
        _build_tree()
