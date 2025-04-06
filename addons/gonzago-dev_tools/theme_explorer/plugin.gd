@tool
extends GonzagoEditorPlugin
## Gonzago.DevTools.ThemeExplorer editor plugin
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

# # https://github.com/godotengine/godot/blob/master/editor/plugins/theme_editor_plugin.cpp

const ThemeExplorer := preload("./views_old/explorer.tscn")
const MainView := preload("./views/main_view.tscn")

var _include_old := true

var _theme_explorer: Control
var _main_view: Control


func _enter_tree() -> void:
    if _include_old:
        _theme_explorer = ThemeExplorer.instantiate() as Control
        add_control_to_bottom_panel(_theme_explorer, "Theme Explorer (old)")
    
    _main_view = MainView.instantiate() as Control
    add_control_to_bottom_panel(_main_view, "Theme Explorer")


func _exit_tree() -> void:
    if _main_view:
        remove_control_from_bottom_panel(_main_view)
        _main_view.queue_free()
    
    if _theme_explorer:
        remove_control_from_bottom_panel(_theme_explorer)
        _theme_explorer.queue_free()
