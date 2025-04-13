@tool
@static_unload
class_name Gonzago
extends RefCounted
## Gonzago utilities and namespace class.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Utils

const FileSystemUtil := preload("uid://bcpigtqn6gme5")
const OSUtil := preload("uid://dul686ccryoxe")
const ProjectSettingsUtil := preload("uid://dmvlxlci5itta")

const ReflectionUtil := preload("uid://cenwmdv5qsbev")
const VersioningUtil := preload("uid://5wqkf3i5nb70")

const VariantUtil := preload("uid://jhwgwna1yvl")
const StringUtil := preload("uid://dwrtug1qdumht")
const ArrayUtil := preload("uid://ck86wp0vihbmi")
const DictionaryUtil := preload("uid://cnx2fdk5112q6")
const BitmaskUtil := preload("uid://bu33pjmob30e5")

const NodeUtil := preload("uid://bpxw7qtl8y5sb")
const ControlUtil := preload("uid://bpslqqsphuldy")

const ResourceUtil := preload("uid://ogocoog1tu2b")
const PackedSceneUtil := preload("uid://d1ihue386potd")
const ThemeUtil := preload("uid://c3sdnkw6upi7u")

#endregion
