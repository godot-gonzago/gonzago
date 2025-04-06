@tool
extends Container

# https://github.com/godotengine/godot/blob/master/editor/editor_inspector.h
# https://github.com/godotengine/godot/blob/master/editor/editor_inspector.cpp
# https://github.com/SirLich/gd-explorer
# https://github.com/wareya/ScrollListContainer/tree/main
# https://docs.godotengine.org/en/stable/classes/class_editorproperty.html

enum DisplayMode {
    DISPLAY_MODE_LIST,
    DISPLAY_MODE_THUMBNAIL
}

class ListElementButton extends Object:
    var disabled: bool = true
    var visible: bool = true
    var icon: Texture2D

class ListElement extends Object:
    var selectable: bool = true
    var disabled: bool = true
    var visible: bool = true
    var icon: Texture2D
    var text: String
    var editable_text: bool = false
    var tooltip: String
    var tooltip_enabled: bool
    var buttons: Array[ListElementButton]
    var metadata: Variant

class ListGroup extends ListElement:
    # TODO: Collapsable group like tree or inspector
    var folded: bool

class ListItem extends ListElement:
    # TODO: Regular view: 2 Columns like inspector
    #       Editable label, Buttons after the label (hidden in thumbnail mode)
    #       Control on the right side
    #       Thumbnail drawing registerable callback in thumbnail mode
    var custom_control: Control
    var custom_preview_callback: Callable


func _init() -> void:
    set_notify_transform(true)
