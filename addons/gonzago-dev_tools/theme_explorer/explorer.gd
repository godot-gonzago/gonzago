@tool
extends VBoxContainer


const ThemeTree := preload("./theme_tree.gd")


func _enter_tree() -> void:
    inspect_editor_theme()


func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    var bg := get_theme_stylebox("BottomPanelDebuggerOverride", "EditorStyles")
    draw_style_box(bg, rect)


func inspect_editor_theme() -> void:
    var editor_theme := EditorInterface.get_editor_theme()
    inspect(editor_theme)


func inspect(t: Theme) -> void:
    var tree := get_node("%ThemeTree") as ThemeTree
    tree.inspect(t)



class ThemeCache extends Object:
    var _tags := {}
    var _data_types := [
        DataTypeCache.new(), # Colors
        DataTypeCache.new(), # Constants
        DataTypeCache.new(), # Fonts
        DataTypeCache.new(), # Font sizes
        DataTypeCache.new(), # Icons
        DataTypeCache.new()  # Styleboxes
    ]
    var _types: Dictionary = {}
    var _items: Dictionary = {}
    var _base: ThemeCache = null

    func get_types() -> Array[StringName]:
        # can now be joined with base theme?
        return []

    func get_type_base_info() -> void:
        # can now be joined with base theme?
        return

class TagCache extends Object:
    var tag: StringName
    var matching: bool = true

    var types: Array[StringName] = []
    var items: Array[StringName] = []

class DataTypeCache extends Object:
    var matching: bool = true

    var types: Array[StringName] = []
    var items: Array[StringName] = []

class ThemeTypeCache extends Object:
    var matching: bool = true

    var variations: Array[StringName] = []
    var base_type: StringName

class ThemeItemCache extends Object:
    var data_type: int
    var theme_type: StringName
    var name: StringName

    var matching: bool = true
