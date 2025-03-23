@tool
extends HBoxContainer

# TODO: https://docs.godotengine.org/en/stable/classes/class_projectsettings.html#class-projectsettings-property-gui-theme-custom
#       https://docs.godotengine.org/en/stable/classes/class_editorplugin.html#class-editorplugin-private-method-get-window-layout
#       Add theme creation options
#       Save last open themes and reopen next time
#       Add display options for entry views (theme resources, data types, theme types view) or detail view (eg. Text to display or image background)
#       get_theme_icon("Checkerboard", "EditorIcons") as a background for example

# TODO: Dont allow to close editor. defaiöt or project theme
#       Allow manipulation of project theme
#       Find project theme in project settings and enable or disable tab based on result
#       When opening a theme check if project theme and show in project tab instead of file tab
#       Behaviour should be the same as any other theme files

#var _tabs := TabBar.new()
#var _new := Button.new()
#var _open := Button.new()
#var _save := Button.new()
#var _tools := Button.new()
#var _options := Button.new()
#
#func _init() -> void:
#    set_anchors_preset(Control.PRESET_TOP_WIDE)
#    
#    _tabs 
#    _tabs.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
#    _tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#    _tabs.size_flags_vertical = Control.SIZE_SHRINK_END
#    add_child(_tabs)
#    
#    _tabs.add_tab("Editor")
#    _tabs.add_tab("Default")
#    _tabs.add_tab("Project")
#    _tabs.set_tab_disabled(2, true)
#    
#    _new.flat = true
#    add_child(_new)
#    _open.flat = true
#    add_child(_open)
#    _save.flat = true
#    _save.disabled = true
#    add_child(_save)
#    _tools.flat = true
#    add_child(_tools)
#    add_child(HSeparator.new())
#    _options.flat = true
#    add_child(_options)
#
#
#func _notification(what: int) -> void:
#    match what:
#        NOTIFICATION_THEME_CHANGED:
#            _tabs.set_tab_icon(0, get_theme_icon("GuiVisibilityXray", "EditorIcons"))
#            _tabs.set_tab_icon(1, get_theme_icon("GuiVisibilityXray", "EditorIcons"))
#            _tabs.set_tab_icon(2, get_theme_icon("Theme", "EditorIcons"))
#            
#            _new.icon = get_theme_icon("New", "EditorIcons")
#            _open.icon = get_theme_icon("Load", "EditorIcons")
#            _save.icon = get_theme_icon("Save", "EditorIcons")
#            _tools.icon = get_theme_icon("Tools", "EditorIcons")
#            _options.icon = get_theme_icon("GuiTabMenuHl", "EditorIcons")
#        NOTIFICATION_TRANSLATION_CHANGED:
#            _tabs.set_tab_title(0, tr("Editor"))
#            _tabs.set_tab_title(1, tr("Default"))
#            _tabs.set_tab_title(2, tr("Project"))
