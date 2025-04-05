@tool
@static_unload
extends RefCounted

class GlobalSettings extends RefCounted:
    var theme_uids := PackedInt32Array() # loaded themes
    var inspected_idx := -1 # selected tab?
    var mode := -1 # items, preview, resources
    
    var show_default := true
    var display_background := -1


class ThemeSettings extends RefCounted:
    var uid: int
    var selected_type: StringName
    var selected_data_type: Theme.DataType
    var selected_item: StringName
