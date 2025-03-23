@tool
extends "res://addons/gonzago-dev_tools/theme_explorer/item.gd"

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_FONT, name, type) as Font
    var previewer := get_node("%TextEdit") as Label
    previewer.add_theme_font_override("font", item)
    
    var font_size_name := name + "_size"
    var font_size_list := t.get_font_size_list(type)
    if font_size_name in font_size_list:
        var label := get_node("%BottomLabel") as Label
        label.text = "%s (%s)" % [name, font_size_name]
        tooltip_text = label.text
        
        var font_size := t.get_font_size(font_size_name, type)
        previewer.add_theme_font_size_override("font_size", font_size)
