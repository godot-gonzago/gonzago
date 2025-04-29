@tool
extends GonzagoEditorPlugin
## Gonzago.DevTools.ThemeExplorer editor plugin
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

# # https://github.com/godotengine/godot/blob/master/editor/plugins/theme_editor_plugin.cpp

const ThemeExplorer := preload("uid://mpanmyvqc6u5")
const MainView := preload("uid://rdphd1mywfyv")

var _include_old := true

var _theme_explorer: Control
var _main_view: Control


func _enter_tree() -> void:
    if _include_old:
        _theme_explorer = ThemeExplorer.instantiate() as Control
        add_control_to_bottom_panel(_theme_explorer, "Theme Explorer (old)")

    _main_view = MainView.instantiate() as Control
    add_control_to_bottom_panel(_main_view, "Theme Explorer")

    #var editor_theme := EditorInterface.get_editor_theme()
    #var properties := editor_theme.get_property_list()
    #for dict in properties:
    #    print(dict)


func _exit_tree() -> void:
    if _main_view:
        remove_control_from_bottom_panel(_main_view)
        _main_view.queue_free()

    if _theme_explorer:
        remove_control_from_bottom_panel(_theme_explorer)
        _theme_explorer.queue_free()
