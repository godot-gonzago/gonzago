@tool
@static_unload
class_name GonzagoEditor
extends RefCounted
## Gonzago editor utilities and namespace class.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Utils

const EditorSettingsUtil := preload("./utils/editor_settings.gd")
const FileSystemUtil := preload("./utils/file_system.gd")

#endregion
