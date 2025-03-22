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
    
    #_tree.custom_minimum_size = Vector2(100, 100)
    _popup.add_child(_tree)
    
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
    pass
    #var popup := get_popup()
    #popup.clear(true)
    #_build_children(popup, GonzagoEditorPluginRegistry.get_plugins(), true)


func _build_children(menu: PopupMenu, children: Array[GonzagoEditorPluginRegistry.PluginInfo], root := false) -> void:
    for info in children:
        var index := menu.item_count
        menu.add_item(info.get_display_name())
        if info.children.size() > 0:
            var submenu := PopupMenu.new()
            menu.set_item_submenu_node(index, submenu)
            _build_children(submenu, info.children)
            
        if info.plugin_id == DEV_TOOLS_PLUGIN:
            var icon := menu.get_theme_icon("Reload", "EditorIcons")
            menu.set_item_icon(index, icon)
        else:
            menu.set_item_as_checkable(index, true)
            menu.set_item_checked(index, info.is_enabled())
        menu.set_item_metadata(index, info)
        menu.set_item_disabled(index, not root)


func _toggle_plugin_enabled(index: int) -> void:
    pass
    #var popup := get_popup()
    #var info := popup.get_item_metadata(index) as GonzagoEditorPluginRegistry.PluginInfo
#
    #if info.plugin_id == DEV_TOOLS_PLUGIN:
        #info.reload_deffered()
        #return
    #
    #info.toggle()
    #popup.set_item_checked(index, info.is_enabled())
