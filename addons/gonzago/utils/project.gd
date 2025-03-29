@tool
extends RefCounted
## Project related utilities.
##
## Utility functions for [ProjectSettings].


## Ensures that the project settings identified by [param name] exists and
## is properly configured.
static func ensure_project_setting(
        name: String,
        property_info: Dictionary,
        initial_value: Variant,
        restart: bool = false
) -> void:
    if not ProjectSettings.has_setting(name):
        ProjectSettings.set_setting(name, initial_value)
    ProjectSettings.add_property_info(property_info)
    ProjectSettings.set_initial_value(name, initial_value)
    ProjectSettings.set_restart_if_changed(name, restart)


## Returns the value of the setting identified by [param name] and applies feature tag
## overrides if any exists and is valid. If the setting doesn't exist and [param default]
## is specified, the value of [param default] is returned.
## Otherwise, [code]null[/code] is returned.
static func get_project_setting_with_override(name: String, default: Variant = null) -> Variant:
    if not ProjectSettings.has_setting(name):
        return default
    return ProjectSettings.get_setting_with_override(name)
