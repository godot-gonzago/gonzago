@tool
@static_unload
class_name Gonzago
extends RefCounted
## Gonzago utilities and namespace class.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

#region Utils

const FileSystemUtil := preload("./utils/reflection.gd")
const ProjectSettingsUtil := preload("./utils/project_settings.gd")
const ReflectionUtil := preload("./utils/reflection.gd")
const VersioningUtil := preload("./utils/versioning.gd")

const VariantUtil := preload("./utils/variant/variant.gd")
const StringUtil := preload("./utils/variant/string.gd")
const ArrayUtil := preload("./utils/variant/array.gd")
const DictionaryUtil := preload("./utils/variant/dictionary.gd")

const NodeUtil := preload("./utils/scene/node.gd")
const ControlUtil := preload("./utils/scene/control.gd")

const ResourceUtil := preload("./utils/resource/resource.gd")
const PackedSceneUtil := preload("./utils/resource/packed_scene.gd")
const ThemeUtil := preload("./utils/resource/theme.gd")

#endregion
