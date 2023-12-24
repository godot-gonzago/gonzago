@tool
extends VBoxContainer


func _enter_tree() -> void:
    var editor_theme := EditorInterface.get_editor_theme()
    inspect(editor_theme)


func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    var bg := get_theme_stylebox("BottomPanelDebuggerOverride", "EditorStyles")
    draw_style_box(bg, rect)


func inspect(t : Theme) -> void:
    pass


var _editor_theme_cache: ThemeCache
var _default_theme_cache: ThemeCache
var _theme_file_caches: Dictionary


class ThemeCache extends RefCounted:
    enum ThemeType {
        INTERNAL,
        PROJECT,
        RESOURCE
    }

    var type: ThemeType
    var resource_uid: String

    var tags: Array[StringName]
    var data_types: Array[int]
    var types: Array[StringName]
    var entries: Array[StringName]

class ThemeEntryCache extends RefCounted:
    var data_type: int
    var theme_type: StringName
    var name: StringName
