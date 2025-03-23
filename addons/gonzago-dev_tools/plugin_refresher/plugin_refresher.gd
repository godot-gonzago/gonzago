@tool
extends Button

## Adds a toolbar button for instantly enabling/disabling plugins.
## Based on the idea by willnationsdev,
## see https://github.com/godot-extended-libraries/godot-plugin-refresher


const DEV_TOOLS_PLUGIN := "gonzago-dev_tools"


var _popup := PopupPanel.new()
var _tree := Tree.new()


func _init() -> void:
    action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
    focus_mode = Control.FOCUS_NONE
    
    _popup.about_to_popup.connect(_build_tree)
    add_child(_popup)
    
    _tree.custom_minimum_size = Vector2(400, 600) # TODO:
    _tree.hide_root = true
    _tree.item_edited.connect(_toggle_plugin_enabled)
    _tree.button_clicked.connect(_handle_button_clicks)
    _popup.add_child(_tree)
    
    pressed.connect(_show_popup)
    
    
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_THEME_CHANGED:
            icon = get_theme_icon("EditorPlugin", "EditorIcons")
            _update_tree_items(_update_tree_item_icons)
        NOTIFICATION_TRANSLATION_CHANGED:
            tooltip_text = tr("Plugins")
            _update_tree_items(_update_tree_item_texts)
    

func _show_popup() -> void:
    var rect := get_global_rect()
    rect.position.y += rect.size.y
    rect.size = _popup.get_contents_minimum_size()
    _popup.popup_on_parent(rect)


func _build_tree() -> void:
    _tree.clear()
    
    var root := _tree.create_item()
    var plugins := GonzagoEditorPluginRegistry.get_plugins()
    
    var stack: Array = []
    stack.push_back(plugins)
    stack.push_back(root)
    
    while not stack.is_empty():
        var parent: TreeItem = stack.pop_back() as TreeItem
        var entries: Array[GonzagoEditorPluginRegistry.PluginInfo] = stack.pop_back() as Array[GonzagoEditorPluginRegistry.PluginInfo]
        
        for info in entries:
            var item := _tree.create_item(parent)
            var editable := info.is_root and info.plugin_id != DEV_TOOLS_PLUGIN
            
            item.set_metadata(0, info)
            item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
            item.set_editable(0, editable)
            
            item.set_text(0, info.get_display_name())
            var tooltip := (
                "Name: %s\n" % info.get_display_name() +
                "Path: %s\n" % info.config_path +
                "Main Script: %s" % info.script_path
            )
            if not info.description.is_empty():
                tooltip += "\n\n\n%s" % info.description
            item.set_tooltip_text(0, tooltip)
            
            item.add_button(0, ThemeDB.fallback_icon)
            item.add_button(0, ThemeDB.fallback_icon)
            
            if info.children.size() > 0:
                stack.push_back(info.children)
                stack.push_back(item)
                
    _update_tree_items(
        func(item: TreeItem):
            _update_tree_item_icons(item)
            _update_tree_item_texts(item)
            _update_tree_item_checked(item)
    )
                
                
func _update_tree_items(item_updater: Callable) -> void:
    var root := _tree.get_root()
    if not root:
        return
    
    var stack := root.get_children()
    while not stack.is_empty():
        var item: TreeItem = stack.pop_back() as TreeItem
        item_updater.call(item)
        stack.append_array(item.get_children())


func _update_tree_item_icons(item: TreeItem) -> void:
    item.set_button(0, 0, get_theme_icon("Reload", "EditorIcons"))
    item.set_button(0, 1, get_theme_icon("Edit", "EditorIcons"))
    

func _update_tree_item_texts(item: TreeItem) -> void:
    item.set_button_tooltip_text(0, 0, tr("Reload"))
    item.set_button_tooltip_text(0, 1, tr("Edit"))
    
    
func _update_tree_item_checked(item: TreeItem) -> void:
    var info := item.get_metadata(0) as GonzagoEditorPluginRegistry.PluginInfo
    item.set_checked(0, info.is_enabled())
    item.set_button_disabled(0, 0, not info.is_enabled())


func _toggle_plugin_enabled() -> void:
    var item := _tree.get_edited()
    var info := item.get_metadata(0) as GonzagoEditorPluginRegistry.PluginInfo
    var editable := info.is_root and info.plugin_id != DEV_TOOLS_PLUGIN
    if editable:
        info.toggle()
        _update_tree_items(_update_tree_item_checked)


func _handle_button_clicks(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
    var info := item.get_metadata(0) as GonzagoEditorPluginRegistry.PluginInfo
    if id == 0: # Reload
        if info.is_enabled():
            info.reload_deffered()
            call_deferred("_update_tree_items", _update_tree_item_checked)
    elif id == 1: # Edit
        pass
