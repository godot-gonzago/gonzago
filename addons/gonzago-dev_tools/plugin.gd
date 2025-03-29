@tool
extends GonzagoEditorPlugin
## Gonzago.DevTools editor plugin.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html


const CONFIG_FILE_NAME := "plugin.cfg"
const DEV_TOOLS_PLUGIN := "gonzago-dev_tools"
const DEV_TOOLS_ROOT := "res://addons/gonzago-dev_tools"


func _enable_plugin() -> void:
    for plugin_name in DirAccess.get_directories_at(DEV_TOOLS_ROOT):
        var plugin_path := DEV_TOOLS_ROOT.path_join(plugin_name)
        var config_path := plugin_path.path_join(CONFIG_FILE_NAME)
        if not FileAccess.file_exists(config_path):
            continue

        EditorInterface.set_plugin_enabled(DEV_TOOLS_PLUGIN.path_join(plugin_name), true)


func _disable_plugin() -> void:
    for plugin_name in DirAccess.get_directories_at(DEV_TOOLS_ROOT):
        var plugin_path := DEV_TOOLS_ROOT.path_join(plugin_name)
        var config_path := plugin_path.path_join(CONFIG_FILE_NAME)
        if not FileAccess.file_exists(config_path):
            continue

        EditorInterface.set_plugin_enabled(DEV_TOOLS_PLUGIN.path_join(plugin_name), false)
