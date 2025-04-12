@tool
extends LineEdit

signal filters_changed(filters: PackedStringArray)


func _on_text_changed(new_text: String) -> void:
    var filters := new_text.split(" ", false)
    filters_changed.emit(filters)
