@tool
extends EditorPlugin


const PluginRefresher := preload("./plugin_refresher.gd")
const ThemeExplorer := preload("./theme_explorer/explorer.tscn")


var _plugin_refresher: PluginRefresher
var _theme_explorer: Control


func _enter_tree() -> void:
    _plugin_refresher = PluginRefresher.new()
    add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_refresher)

    _theme_explorer = ThemeExplorer.instantiate() as Control
    add_control_to_bottom_panel(_theme_explorer, "Theme Explorer")


func _exit_tree() -> void:
    if _plugin_refresher:
        remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _plugin_refresher)
        _plugin_refresher.queue_free()

    if _theme_explorer:
        remove_control_from_bottom_panel(_theme_explorer)
        _theme_explorer.queue_free()
