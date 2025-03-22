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
    
    # TODO:
    _tree.custom_minimum_size = Vector2(400, 600)
    _tree.hide_root = true
    #_tree.columns = 2
    #_tree.set_column_expand(0, true)
    #_tree.set_column_expand(1, false)
    _popup.add_child(_tree)
    _popup.about_to_popup.connect(_build_plugin_list)
    _tree.item_edited.connect(_toggle_plugin_enabled)
    
    add_child(_popup)
    pressed.connect(_on_button_pressed)
    

func _on_button_pressed() -> void:
    var rect := get_global_rect()
    rect.position.y += rect.size.y
    rect.size = _popup.get_contents_minimum_size()
    _popup.popup_on_parent(rect)
    
    
func _notification(what: int) -> void:
    match what:
        #NOTIFICATION_READY:
        #    var popup := get_popup()
        #    popup.hide_on_checkable_item_selection = false
        #    popup.about_to_popup.connect(_build_plugin_list)
        #    popup.index_pressed.connect(_toggle_plugin_enabled)
        NOTIFICATION_THEME_CHANGED:
            icon = get_theme_icon("EditorPlugin", "EditorIcons")
        NOTIFICATION_TRANSLATION_CHANGED:
            tooltip_text = tr("Plugins")


func _build_plugin_list() -> void:
    _tree.clear()
    var root := _tree.create_item()
    var plugins := GonzagoEditorPluginRegistry.get_plugins()
    _build_children(root, plugins, true)


func _build_children(parent: TreeItem, entries: Array[GonzagoEditorPluginRegistry.PluginInfo], root := false) -> void:
    for info in entries:
        var item := _tree.create_item(parent)
        item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
        item.set_checked(0, info.is_enabled())
        
        item.set_text(0, info.get_display_name())
        item.set_editable(0, root and info.plugin_id != DEV_TOOLS_PLUGIN)
        item.set_metadata(0, info)
        
        item.add_button(0, get_theme_icon("Reload", "EditorIcons"))
        item.set_button_disabled(0, 0, not info.is_enabled())
        item.add_button(0, get_theme_icon("Edit", "EditorIcons"))
        
        if info.children.size() > 0:
            _build_children(item, info.children)
            
        if info.plugin_id == DEV_TOOLS_PLUGIN:
            pass
            #var icon := menu.get_theme_icon("Reload", "EditorIcons")
            #menu.set_item_icon(index, icon)
        else:
            pass
            #menu.set_item_as_checkable(index, true)
            #menu.set_item_checked(index, info.is_enabled())
        #menu.set_item_metadata(index, info)
        #menu.set_item_disabled(index, not root)


func _toggle_plugin_enabled() -> void:
    var item := _tree.get_edited()
    var info := item.get_metadata(0) as GonzagoEditorPluginRegistry.PluginInfo
    
    if info.plugin_id == DEV_TOOLS_PLUGIN:
        info.reload_deffered()
        return
        
    info.toggle()
    item.set_checked(0, info.is_enabled())
