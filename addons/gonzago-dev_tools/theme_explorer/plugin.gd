@tool
extends GonzagoEditorPlugin
## Gonzago.DevTools.ThemeExplorer editor plugin
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html


const ThemeExplorer := preload("./explorer.tscn")


var _theme_explorer: Control


func _enter_tree() -> void:
    _theme_explorer = ThemeExplorer.instantiate() as Control
    add_control_to_bottom_panel(_theme_explorer, "Theme Explorer")


func _exit_tree() -> void:
    if _theme_explorer:
        remove_control_from_bottom_panel(_theme_explorer)
        _theme_explorer.queue_free()
