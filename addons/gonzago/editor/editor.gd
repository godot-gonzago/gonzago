@tool
@static_unload
class_name GonzagoEditor
extends RefCounted
## Gonzago editor utilities and namespace class.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Utils

const EditorSettingsUtil := preload("uid://c77um0n8vpuew")
const FileSystemUtil := preload("uid://bdl38mynm4ur8")

#endregion

#region Assets

static var GonzagoIcon := preload("uid://641b4h8qe3jb") as Texture2D

#endregion
