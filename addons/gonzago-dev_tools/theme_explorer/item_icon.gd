@tool
extends "res://addons/gonzago-dev_tools/theme_explorer/item.gd"

# TODO: Consolitate all data types into one item

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_ICON, name, type) as Texture2D
    var previewer := get_node("%TextureRect") as TextureRect
    
    var size := previewer.get_combined_minimum_size()
    if size.x < item.get_width() or size.y < item.get_height():
        previewer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        previewer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    else:
        previewer.expand_mode = TextureRect.EXPAND_KEEP_SIZE
        previewer.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
    
    previewer.texture = item
