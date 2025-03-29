@tool
extends RefCounted

enum ThemeType {
    EDITOR = 0,
    DEFAULT = 1,
    PROJECT = 2,
    RESOURCE = 3
}

var theme: Theme


func _init(theme: Theme) -> void:
    self.theme = theme


func get_theme_type() -> ThemeType:
    if theme == EditorInterface.get_editor_theme():
        return ThemeType.EDITOR
    if theme == ThemeDB.get_default_theme():
        return ThemeType.DEFAULT
    var project_theme := ThemeDB.get_project_theme()
    if project_theme and theme == project_theme:
        return ThemeType.PROJECT
    return ThemeType.RESOURCE


func is_read_only() -> bool:
    return get_theme_type() >= ThemeType.PROJECT


func get_base_theme() -> Theme:
    if get_theme_type() >= ThemeType.PROJECT:
        return ThemeDB.get_default_theme()
    return null
