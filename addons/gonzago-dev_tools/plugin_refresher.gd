@tool
extends MenuButton

## Adds a toolbar button for instantly enabling/disabling plugins.
## Based on the idea by willnationsdev,
## see https://github.com/godot-extended-libraries/godot-plugin-refresher


const PLUGINS_ROOT := "res://addons"
const CONFIG_FILE_NAME := "plugin.cfg"
const DEV_TOOLS_PLUGIN := "gonzago-dev_tools"


func _ready() -> void:
    var popup := get_popup()
    popup.hide_on_checkable_item_selection = false
    popup.about_to_popup.connect(_build_plugin_list)
    popup.index_pressed.connect(_toggle_plugin_enabled)

    icon = get_theme_icon("EditorPlugin", "EditorIcons")
    tooltip_text = tr("Plugins")


func _build_plugin_list() -> void:
    var popup := get_popup()
    popup.clear()

    for plugin_name in DirAccess.get_directories_at(PLUGINS_ROOT):
        var plugin_path := PLUGINS_ROOT.path_join(plugin_name)
        var config_path := plugin_path.path_join(CONFIG_FILE_NAME)
        if not FileAccess.file_exists(config_path):
            continue

        var config := ConfigFile.new()
        if config.load(config_path) == OK and config.has_section_key("plugin", "name"):
            var display_name := str(config.get_value("plugin", "name"))
            var index := popup.get_item_count()
            if plugin_name == DEV_TOOLS_PLUGIN:
                var icon := popup.get_theme_icon("Reload", "EditorIcons")
                popup.add_icon_item(icon, display_name if not display_name.is_empty() else plugin_name)
            else:
                popup.add_check_item(display_name if not display_name.is_empty() else plugin_name)
                popup.set_item_checked(index, EditorInterface.is_plugin_enabled(plugin_name))
            popup.set_item_metadata(index, plugin_name)
            #popup.set_item_disabled(index, plugin_name == DEV_TOOLS_PLUGIN)


func _toggle_plugin_enabled(index: int) -> void:
    var popup := get_popup()
    var plugin_name := str(popup.get_item_metadata(index))

    if plugin_name == DEV_TOOLS_PLUGIN:
        EditorInterface.call_deferred("set_plugin_enabled", plugin_name, false)
        EditorInterface.call_deferred("set_plugin_enabled", plugin_name, true)
        return

    var enabled := not EditorInterface.is_plugin_enabled(plugin_name)
    EditorInterface.set_plugin_enabled(plugin_name, enabled)

    popup.set_item_checked(index, enabled)
