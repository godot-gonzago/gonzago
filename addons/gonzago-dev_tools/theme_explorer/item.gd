@tool
extends Container

func inspect(t: Theme, type: StringName, name: StringName) -> void:
    var label := get_node("%BottomLabel") as Label
    label.text = name
    label.tooltip_text = name
