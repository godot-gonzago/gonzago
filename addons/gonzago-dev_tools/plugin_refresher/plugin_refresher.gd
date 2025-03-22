@tool
extends MenuButton

## Adds a toolbar button for instantly enabling/disabling plugins.
## Based on the idea by willnationsdev,
## see https://github.com/godot-extended-libraries/godot-plugin-refresher


const PLUGINS_ROOT := "res://addons/"
const CONFIG_FILE_NAME := "plugin.cfg"
const DEV_TOOLS_PLUGIN := "gonzago-dev_tools"


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_READY:
            var popup := get_popup()
            popup.hide_on_checkable_item_selection = false
            popup.about_to_popup.connect(_build_plugin_list)
            popup.index_pressed.connect(_toggle_plugin_enabled)
        NOTIFICATION_THEME_CHANGED:
            icon = get_theme_icon("EditorPlugin", "EditorIcons")
        NOTIFICATION_TRANSLATION_CHANGED:
            tooltip_text = tr("Plugins")


func _build_plugin_list() -> void:
    var popup := get_popup()
    popup.clear()

    for info in GonzagoEditor.get_plugins():
        var index := popup.get_item_count()
        if info.plugin_id == DEV_TOOLS_PLUGIN:
            var icon := popup.get_theme_icon("Reload", "EditorIcons")
            popup.add_icon_item(icon, info.get_display_name())
        else:
            popup.add_check_item(info.get_display_name())
            popup.set_item_checked(index, info.is_enabled())
        popup.set_item_metadata(index, info)
        #popup.set_item_disabled(index, info.plugin_id == DEV_TOOLS_PLUGIN)


func _toggle_plugin_enabled(index: int) -> void:
    var popup := get_popup()
    var info := popup.get_item_metadata(index) as GonzagoEditor.PluginInfo

    if info.plugin_id == DEV_TOOLS_PLUGIN:
        info.reload_deffered()
        return
    
    info.toggle()
    popup.set_item_checked(index, info.is_enabled())
