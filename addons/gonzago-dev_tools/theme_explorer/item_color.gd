@tool
extends "res://addons/gonzago-dev_tools/theme_explorer/item.gd"

# TODO: Consolitate all data types into one item

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_COLOR, name, type) as Color
    var previewer := get_node("%ColorRect") as ColorRect
    previewer.color = item
