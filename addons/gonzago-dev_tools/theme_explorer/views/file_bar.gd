@tool
extends HBoxContainer


signal theme_selected(theme: Theme)

var _file_tabs: TabBar
var _create_button: Button
var _open_button: Button
var _save_button: Button
var _file_create_dialog: EditorFileDialog
var _file_open_dialog: EditorFileDialog

@export var auto_select_on_ready := true

@export var can_create: bool = true:
    get:
        return _create_button.visible
    set(value):
        _create_button.visible = value

@export var can_open: bool = true:
    get:
        return _open_button.visible
    set(value):
        _open_button.visible = value

@export var can_save: bool = true:
    get:
        return _save_button.visible
    set(value):
        _save_button.visible = value


func _init() -> void:
    set_anchors_preset(Control.PRESET_TOP_WIDE)
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    _file_tabs = TabBar.new()
    _file_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _file_tabs.size_flags_vertical = Control.SIZE_SHRINK_END
    _file_tabs.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_NEVER
    _file_tabs.drag_to_rearrange_enabled = true
    _file_tabs.add_tab("Editor")
    _file_tabs.add_tab("Default")
    _file_tabs.add_tab("Project")
    add_child(_file_tabs)
    
    _create_button = Button.new()
    _create_button.flat = true
    add_child(_create_button)
    _open_button = Button.new()
    _open_button.flat = true
    add_child(_open_button)
    _save_button = Button.new()
    _save_button.flat = true
    _save_button.disabled = true
    add_child(_save_button)
    
    var theme_resource_filters := PackedStringArray()
    for e in ResourceLoader.get_recognized_extensions_for_type("Theme"):
        theme_resource_filters.append("*.%s;%s" % [e, e.to_upper()])
    
    _file_create_dialog = EditorFileDialog.new()
    _file_create_dialog.filters = theme_resource_filters
    add_child(_file_create_dialog, false, Node.INTERNAL_MODE_FRONT)
    
    _file_open_dialog = EditorFileDialog.new()
    _file_open_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    _file_open_dialog.filters = theme_resource_filters
    add_child(_file_open_dialog, false, Node.INTERNAL_MODE_FRONT)
    
    #_file_open_type_missmatch = AcceptDialog.new()
    #_file_open_dialog.add_child(_file_open_type_missmatch)
    
    if NodeUtil.is_node_being_edited(self):
        return
    
    _file_tabs.tab_changed.connect(_tab_changed)
    _file_tabs.tab_close_pressed.connect(_tab_close_pressed)
    _file_tabs.tab_hovered.connect(_tab_hovered)
    _file_tabs.active_tab_rearranged.connect(_active_tab_rearranged)
    _check_project_theme_tab()
    ProjectSettings.settings_changed.connect(_check_project_theme_tab)
    
    _file_create_dialog.file_selected.connect(_file_create_selected)
    _file_open_dialog.file_selected.connect(_file_open_selected)
    
    _create_button.pressed.connect(_file_create_dialog.popup_file_dialog)
    _open_button.pressed.connect(_file_open_dialog.popup_file_dialog)


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            if NodeUtil.is_node_being_edited(self):
                return
            #if auto_select_on_ready:
            #    _file_tabs.select_next_available()
            # TODO: Save and check history of open files and selected tabs etc.
            # https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-private-method-get-window-layout
        NOTIFICATION_TRANSLATION_CHANGED:
            _file_tabs.set_tab_title(0, tr("Editor"))
            _file_tabs.set_tab_tooltip(0, tr("Editor Theme"))
            _file_tabs.set_tab_title(1, tr("Default"))
            _file_tabs.set_tab_tooltip(1, tr("Default Theme"))
            _file_tabs.set_tab_title(2, tr("Project"))
            _file_tabs.set_tab_tooltip(2, tr("Project Theme defined in ProjectSettings"))
            
            _file_create_dialog.title = tr("Create Theme Resource")
            _file_open_dialog.title = tr("Open Theme Resource")
            
            _create_button.tooltip_text = tr("Create a new Theme...")
            _open_button.tooltip_text = tr("Open a Theme...")
            _save_button.tooltip_text = tr("Save the current Theme...")
        NOTIFICATION_THEME_CHANGED:
            var read_only_icon := get_theme_icon(&"GuiVisibilityXray", &"EditorIcons")
            var theme_icon := get_theme_icon(&"Theme", &"EditorIcons")
            for tab_idx in range(2):
                _file_tabs.set_tab_icon(tab_idx, read_only_icon)
            _file_tabs.set_tab_icon(2, theme_icon)
            
            #var missing_icon := get_theme_icon(&"MissingResource", &"EditorIcons")
            for tab_idx in range(3, _file_tabs.tab_count):
                _file_tabs.set_tab_icon(tab_idx, theme_icon)
            
            _create_button.icon = get_theme_icon(&"New", &"EditorIcons")
            _open_button.icon = get_theme_icon(&"Load", &"EditorIcons")
            _save_button.icon = get_theme_icon(&"Save", &"EditorIcons")


func _check_project_theme_tab() -> void:
    var project_theme := ThemeDB.get_project_theme()
    _file_tabs.set_tab_metadata(2, project_theme)
    _file_tabs.set_tab_disabled(2, not project_theme)
    if _file_tabs.current_tab == 2:
        _file_tabs.select_previous_available()


func _tab_changed(tab_idx: int) -> void:
    _file_tabs.tab_close_display_policy = (
        TabBar.CLOSE_BUTTON_SHOW_NEVER if tab_idx <= 2 else
        TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
    )
    var theme := _file_tabs.get_tab_metadata(tab_idx) as Theme
    if theme:
        theme_selected.emit(theme)


func _tab_close_pressed(tab_idx: int) -> void:
    if tab_idx <= 2:
        return
    _file_tabs.remove_tab(tab_idx)


func _tab_hovered(tab_idx: int) -> void:
    _file_tabs.drag_to_rearrange_enabled = tab_idx > 2


func _active_tab_rearranged(idx_to: int) -> void:
    if _file_tabs.current_tab <= 2:
        return
    idx_to = mini(3, idx_to)
    _file_tabs.move_tab(_file_tabs.current_tab, idx_to)


func _file_create_selected(path: String) -> void:
    var new_theme := Theme.new()
    new_theme.take_over_path(path)
    if ResourceSaver.save(new_theme, path) != OK:
        push_error("failed saving...")
        return
    
    var tab_idx := _file_tabs.tab_count
    _file_tabs.add_tab(
        path.get_file(),
        get_theme_icon(&"Theme", &"EditorIcons")
    )
    _file_tabs.set_tab_metadata(tab_idx, theme)
    _file_tabs.set_tab_tooltip(tab_idx, path)
    _file_tabs.current_tab = tab_idx

func _file_open_selected(path: String) -> void:
    var theme := ResourceLoader.load(path) as Theme
    if not theme: #ResourceLoader.exists(path, "Theme"):
        var message := AcceptDialog.new()
        message.title = tr("Type missmatch!")
        message.get_label().text = tr("Selected file is not of type Theme!")
        EditorInterface.popup_dialog_centered(message)
        #_file_open_dialog.set_deferred(&"current_file", path)
        #_file_open_dialog.call_deferred(&"popup_file_dialog")
        return
    
    for tab_idx in range(2, _file_tabs.tab_count):
        var tab_theme := _file_tabs.get_tab_metadata(tab_idx) as Theme
        if not tab_theme: continue
        if theme == tab_theme:
            _file_tabs.current_tab = tab_idx
            return
    
    var tab_idx := _file_tabs.tab_count
    _file_tabs.add_tab(
        path.get_file(),
        get_theme_icon(&"Theme", &"EditorIcons")
    )
    _file_tabs.set_tab_metadata(tab_idx, theme)
    _file_tabs.set_tab_tooltip(tab_idx, path)
    _file_tabs.current_tab = tab_idx
