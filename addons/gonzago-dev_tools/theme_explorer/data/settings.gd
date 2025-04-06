@tool
@static_unload
extends RefCounted

# TODO: EditorPlugin _get_window_layout, _set_window_layout
#       https://docs.godotengine.org/en/stable/classes/class_editorsettings.html#class-editorsettings-method-set-project-metadata
#       https://docs.godotengine.org/en/stable/classes/class_editorsettings.html#class-editorsettings-method-get-project-metadata
#       https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-method-queue-save-layout
#       https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-private-method-get-window-layout
#       https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-private-method-set-window-layout

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
