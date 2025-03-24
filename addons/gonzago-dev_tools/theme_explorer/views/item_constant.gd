@tool
extends "./item.gd"

# TODO: Consolitate all data types into one item

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    super(t, type, name)
    
    var item := t.get_theme_item(Theme.DATA_TYPE_CONSTANT, name, type) as int
    var previewer := get_node("%TextEdit") as Label
    previewer.text = str(item)
    # TODO: Guess format
    #       name ends with:
    #       px: size, height, width,
    #           margin, margin_bottom, margin_left, margin_right, margin_top,
    #           padding,
    #           separation, h_separation, v_separation
    #           offset, offset_x, offset_y,
    #           spacing, thickness, border
    #       factor: scale, speed
    #       bool: if 0 or 1 (but only a guess)
