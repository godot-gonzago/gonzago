@tool
extends "res://addons/gonzago-dev_tools/theme_explorer/item.gd"

# TODO: Consolitate all data types into one item

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_CONSTANT, name, type) as int
    var previewer := get_node("%TextEdit") as Label
    previewer.text = str(item)
    # TODO: Guess format
