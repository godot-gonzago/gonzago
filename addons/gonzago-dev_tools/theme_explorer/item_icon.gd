@tool
extends "res://addons/gonzago-dev_tools/theme_explorer/item.gd"

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_ICON, name, type) as Texture2D
    var previewer := get_node("%TextureRect") as TextureRect
    previewer.texture = item
