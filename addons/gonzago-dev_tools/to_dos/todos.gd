@tool
extends VBoxContainer

@onready var _filter := get_node("%Filter") as LineEdit
@onready var _options := get_node("%Options") as MenuButton
@onready var _tree := get_node("%Tree") as Tree

var _dirty := true


func _init() -> void:
    pass


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            _update_theme()

            var fs := EditorInterface.get_resource_filesystem()
            fs.sources_changed.connect(_sources_changed)
            _search_scripts()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _update_theme()


func _update_theme() -> void:
    _filter.right_icon = get_theme_icon(&"Search", &"EditorIcons")
    _options.icon = get_theme_icon(&"GuiTabMenuHl", &"EditorIcons")


func _sources_changed(exist: bool) -> void:
    _dirty = true
    _search_scripts()


func _search_scripts() -> void:
    _tree.clear()
    _tree.create_item()

    var fs := EditorInterface.get_resource_filesystem()
    var dir := fs.get_filesystem()
    _search_sub_dirs(fs, dir)


func _search_sub_dirs(fs: EditorFileSystem, dir: EditorFileSystemDirectory) -> void:
    for file_idx in dir.get_file_count():
        var file_type := dir.get_file_type(file_idx)
        if ClassDB.is_parent_class(file_type, &"Script"):
            var file_name := dir.get_file(file_idx)
            var file_path := dir.get_path().path_join(file_name)
            var root := _tree.get_root()
            var item := root.create_child()
            item.set_text(0, file_name)
            item.set_tooltip_text(0, file_path)
    for sub_dir_idx in dir.get_subdir_count():
        var sub_dir := dir.get_subdir(sub_dir_idx)
        _search_sub_dirs(fs, sub_dir)


func _on_tree_item_activated() -> void:
    var item := _tree.get_selected()
    var file_path := item.get_tooltip_text(0)
    var script := ResourceLoader.load(file_path, &"Script") as Script
    EditorInterface.edit_script(script)
