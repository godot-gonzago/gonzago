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
    #       px: size, height, width, margin, padding,
    #           separation, offset, spacing, thickness, border
    #           with optional prefix: h_, v_ (does not need checking)
    #           with optional suffix: _bottom, _top, _left, _right, _x, _y
    #       factor: scale, speed
    #       bool: if value is 0 or 1 (but only guessing)
