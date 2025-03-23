@tool
extends "res://addons/gonzago-dev_tools/theme_explorer/item.gd"

# TODO: Consolitate all data types into one item

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_STYLEBOX, name, type) as StyleBox
    var previewer := get_node("%Panel") as Panel
    previewer.add_theme_stylebox_override("panel", item)
