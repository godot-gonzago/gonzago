@tool
extends "./item.gd"

# TODO: Consolitate all data types into one item

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_FONT_SIZE, name, type) as int
    var previewer := get_node("%TextEdit") as Label
    previewer.add_theme_font_size_override("font_size", item)
    
    var font_name := name.trim_suffix("_size")
    var font_list := t.get_font_list(type)
    if font_name in font_list:
        var label := get_node("%BottomLabel") as Label
        label.text = "%s (%s)" % [name, font_name]
        tooltip_text = label.text
        
        var font := t.get_font(font_name, type)
        previewer.add_theme_font_override("font", font)
