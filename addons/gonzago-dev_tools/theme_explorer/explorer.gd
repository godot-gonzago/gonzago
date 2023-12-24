@tool
extends VBoxContainer


func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    var bg := get_theme_stylebox("BottomPanelDebuggerOverride", "EditorStyles")
    draw_style_box(bg, rect)
