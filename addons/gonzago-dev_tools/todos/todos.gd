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
            _search()
        NOTIFICATION_THEME_CHANGED:
            if is_node_ready():
                _update_theme()


func _update_theme() -> void:
    _filter.right_icon = get_theme_icon(&"Search", &"EditorIcons")
    _options.icon = get_theme_icon(&"GuiTabMenuHl", &"EditorIcons")


func _sources_changed(exist: bool) -> void:
    _dirty = true
    _search()


func _search() -> void:
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
            var icon := _get_icon_for_type(file_type)
            item.set_text(0, file_name)
            item.set_icon(0, icon)
            item.set_tooltip_text(0, file_path)
    for sub_dir_idx in dir.get_subdir_count():
        var sub_dir := dir.get_subdir(sub_dir_idx)
        _search_sub_dirs(fs, sub_dir)


func _search_scripts(script_path: String) -> void:
    var script := ResourceLoader.load(script_path, &"Script") as Script
    if script.has_source_code():
        var value := script.source_code
        # TODO: Check text
        var line := 0
        var column := 0


func _search_scene(scene_path: String) -> void:
    var packed_scene := ResourceLoader.load(scene_path, &"PackedScene") as PackedScene
    var state := packed_scene.get_state()
    for idx in state.get_node_count():
        for prop_idx in state.get_node_property_count(idx):
            if state.get_node_property_name(idx, prop_idx) != &"editor_description":
                continue
            var value := str(state.get_node_property_value(idx, prop_idx))
            # TODO: Check text
            var node_path := state.get_node_path(idx)


func _get_icon_for_type(type: StringName) -> Texture2D:
    var editor_theme := EditorInterface.get_editor_theme()
    while type:
        if editor_theme.has_icon(type, &"EditorIcons"):
            return editor_theme.get_icon(type, &"EditorIcons")
        type = ClassDB.get_parent_class(type)
    return editor_theme.get_icon(&"ObjectDisabled", &"EditorIcons")


func _on_tree_item_activated() -> void:
    var item := _tree.get_selected()
    var file_path := item.get_tooltip_text(0)
    var script := ResourceLoader.load(file_path, &"Script") as Script
    EditorInterface.edit_script(script)


func _data() -> void:
    # https://peps.python.org/pep-0350/#mnemonics
    var tags := [
        "TODO", "[ ]",
        "DONE", "[x]",
        "FIXME", "FIXIT", "FIX",
        "BUG",
        "HACK", "KLUDGE",
        "XXX",
        "INFO",
        "ERROR", "ERR",
        "WARNING", "WARN"
    ]

    var bug := get_theme_icon(&"Debug", &"EditorIcons") # White Bug
    var watch := get_theme_icon(&"GuiVisibilityXray", &"EditorIcons") # Open £ye
    var heath := get_theme_icon(&"Heart", &"EditorIcons") # Heart
    var check := get_theme_icon(&"ImportCheck", &"EditorIcons") # Green Checkmark
    var fail := get_theme_icon(&"ImportFail", &"EditorIcons") # Red X
    var info := get_theme_icon(&"Info", &"EditorIcons") # Question mark in white circle
    var node_info := get_theme_icon(&"NodeInfo", &"EditorIcons") # i in white circle
    var node_warning := get_theme_icon(&"NodeWarning", &"EditorIcons") # Exclamation mark in yellow triangle
    var node_warning_2 := get_theme_icon(&"NodeWarning2", &"EditorIcons") # Exclamation mark in yellow triangle with 2 red dots
    var node_warning_3 := get_theme_icon(&"NodeWarning3", &"EditorIcons") # Exclamation mark in yellow triangle with 3 red dots
    var node_warning_4_plus := get_theme_icon(&"NodeWarning4Plus", &"EditorIcons") # Exclamation mark in yellow triangle with 4 red dots
    var lock := get_theme_icon(&"Lock", &"EditorIcons") # White lock
    var notification := get_theme_icon(&"Notification", &"EditorIcons") # White bell
    var favorites := get_theme_icon(&"Favorites", &"EditorIcons") # White star
    var pin := get_theme_icon(&"Pin", &"EditorIcons") # White pin
    var skeleton := get_theme_icon(&"SkeletonPreview", &"EditorIcons") # White skull
    var status_error := get_theme_icon(&"StatusError", &"EditorIcons") # X in white circle
    var status_success := get_theme_icon(&"StatusSuccess", &"EditorIcons") # Check mark in green circle
    var status_warning := get_theme_icon(&"StatusWarning", &"EditorIcons") # Exclamation mark in yellow circle

    var error_color := get_theme_color(&"error_color", &"Editor") # red
    var success_color := get_theme_color(&"success_color", &"Editor") # green
    var warning_color := get_theme_color(&"warning_color", &"Editor") # yellow
    var property_readonly_warning_color := get_theme_color(&"readonly_warning_color", &"EditorProperty") # dark red
    var property_warning_color := get_theme_color(&"warning_color", &"EditorProperty") # dark yellow
