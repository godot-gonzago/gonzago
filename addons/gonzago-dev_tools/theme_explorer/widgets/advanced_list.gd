@tool
extends Container

# https://github.com/godotengine/godot/blob/master/editor/editor_inspector.h
# https://github.com/godotengine/godot/blob/master/editor/editor_inspector.cpp
# https://github.com/SirLich/gd-explorer
# https://github.com/wareya/ScrollListContainer/tree/main

class Group extends Container:
    # TODO: Collapsable group like tree or inspector
    pass

class Item extends Container:
    # TODO: Regular view: 2 Columns like inspector
    #       Editable label, Buttons after the label (hidden in thumbnail mode)
    #       Control on the right side
    #       Thumbnail drawing registerable callback in thumbnail mode
    pass


func _init() -> void:
    set_notify_transform(true)
