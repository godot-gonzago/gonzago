@tool
extends LineEdit

# TODO: https://www.youtube.com/watch?v=s8ydtU_KNeE

@export var mask: String = "[a-zA-Z0-9 ]"

var _regex := RegEx.new()

func _init() -> void:
    _regex.compile(mask, false)
    text_changed.connect(_text_changed)


func set_mask(mask: String) -> Error:
    self.mask = mask
    var error := _regex.compile(mask)
    update_configuration_warnings()
    return error
    
    
func _get_configuration_warnings() -> PackedStringArray:
    var warnings := PackedStringArray()
    if not _regex.is_valid():
        warnings.append("[i]%s[/i] is not a valid mask." % mask)
    return warnings


func _text_changed(new_text: String) -> void:
    if not _regex.is_valid():
        return
    
    var old_caret_column := caret_column
    var masked_text := ""
    for valid_char in _regex.search_all(new_text):
        masked_text += valid_char.get_string()
    text = masked_text
    caret_column = old_caret_column + (masked_text.length() - new_text.length())
