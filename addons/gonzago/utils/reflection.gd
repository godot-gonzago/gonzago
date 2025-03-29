@tool
@static_unload
extends RefCounted
## Reflection utility.
##
## Reflection utility. Based on
## [url=https://github.com/godot-extended-libraries/godot-next/blob/master/addons/godot-next/references/class_type.gd]this[/url].

#region Script inheritance

## Returns [code]true[/code] if [param script] extends or is equal to [param base_script,
## otherwise [code]false[/code].
static func script_inherits_script(script: Script, base_script: Script) -> bool:
    if not base_script: return false
    while script:
        if script == base_script: return true
        script = script.get_base_script()
    return false


## Returns [code]true[/code] if the provided [param script] has the given
## base [param type], otherwise [code]false[/code].
static func script_inherits_type(script: Script, type: StringName) -> bool:
    if not script: return false
    var instance := script.get_instance_base_type()
    return ClassDB.is_parent_class(instance, type)

#endregion

#region Scene inheritance

## Returns [code]true[/code] if root node of the provided [param scene]
## extends or is equal to the [param base_script], otherwise [code]false[/code].
static func scene_inherits_script(scene: PackedScene, base_script: Script) -> bool:
    var script := get_scene_script(scene)
    return script_inherits_script(script, base_script)


## Returns [code]true[/code] if root node of the provided [param scene]
## is of the given base [param type], otherwise [code]false[/code].
static func scene_inherits_type(scene: PackedScene, type: StringName) -> bool:
    if not scene: return false
    var instance := scene.get_state().get_node_type(0)
    return ClassDB.is_parent_class(instance, type)


## Returns [code]true[/code] if the provided [param scene] inherits or is equal
## to the [param base_scene, otherwise [code]false[/code].
static func scene_inherits_scene(scene: PackedScene, base_scene: PackedScene) -> bool:
    if not base_scene: return false
    while scene:
        if scene == base_scene: return true
        scene = scene.get_state().get_node_instance(0)
    return false


## Returns the script of the root node in the provided [param scene].
static func get_scene_script(scene: PackedScene) -> Script:
    while scene:
        var state := scene.get_state()
        for i in range(state.get_node_property_count(0)):
            var prop_name := state.get_node_property_name(0, i)
            if prop_name == "script":
                return state.get_node_property_value(0, i) as Script
        scene = state.get_node_instance(0)
    return null


## Returns the base type of the root node in the provided [param scene].
## Returns an empty string if [param scene] is invalid.
static func get_scene_type(scene: PackedScene) -> StringName:
    if not scene: return ""
    return scene.get_state().get_node_type(0)

#endregion

#region Instance placeholder inheritance

## Returns [code]true[/code] if the root node of the provided
## [param placeholder] extends or is equal to the [param base_script],
## otherwise [code]false[/code].
static func placeholder_inherits_script(placeholder: InstancePlaceholder, base_script: Script) -> bool:
    var scene := get_placeholder_scene(placeholder)
    return scene_inherits_script(scene, base_script)


## Returns [code]true[/code] if the root node of the provided
## [param placeholder] is of the given base [param type],
## otherwise [code]false[/code].
static func placeholder_inherits_type(placeholder: InstancePlaceholder, type: StringName) -> bool:
    var scene := get_placeholder_scene(placeholder)
    return scene_inherits_type(scene, type)


## Returns [code]true[/code] if [param placeholder] inherits or is equal to
## [param base_scene], otherwise [code]false[/code].
static func placeholdere_inherits_scene(placeholder: InstancePlaceholder, base_scene: PackedScene) -> bool:
    var scene := get_placeholder_scene(placeholder)
    return scene_inherits_scene(scene, base_scene)


## Loads the provided [param placeholder] as a packed scene.
static func get_placeholder_scene(placeholder: InstancePlaceholder) -> PackedScene:
    if not placeholder: return null
    var path := placeholder.get_instance_path()
    return ResourceLoader.load(path, "PackedScene") as PackedScene


## Returns the script of the root node in [param placeholder scene.
## This needs to load the placeholder as a packed scene.
static func get_placeholder_script(placeholder: InstancePlaceholder) -> Script:
    var scene := get_placeholder_scene(placeholder)
    return get_scene_script(scene)


## Returns the base type of the root node in [param placeholder scene.
## This needs to load the placeholder as a packed scene.
static func get_placeholder_type(placeholder: InstancePlaceholder) -> StringName:
    var scene := get_placeholder_scene(placeholder)
    return get_scene_type(scene)
    
#endregion

#region Global type/script handling

## Returns the global class name of the provided [param script].
## If not found returns an empty string.
## @deprecated: Use [method Script.get_global_name] instead.
static func get_global_class_name(script: Script) -> StringName:
    if not script: return ""
    
    for global_class in ProjectSettings.get_global_class_list():
        var script_path := str(global_class.get("path"))
        if script_path.is_empty():
            continue
        if script_path == script.resource_path:
            return str(global_class.get("class"))
            
    return ""


## Returns the editor icon of [param type] or the nearest parent types
## editor icon. [param type] can be a global class name or a base type name.
## If no editor icon could be found in the provided [param theme] or
## [param theme] is invalid [code]null[/code] is returned.
static func get_type_icon(
        type: StringName,
        theme: Theme,
        theme_type: StringName = "EditorIcons"
) -> Texture2D:
    if not theme: return null
    
    # TODO: handle global class names
#    if not ClassDB.class_exists(type):
#        var script_icon_map := Dictionary()
#        for global_class in ProjectSettings.get_global_class_list():
#            var script_name := str(global_class.get("class"))
#            if script_name.is_empty():
#                continue
#            var icon_path := str(global_class.get("icon"))
#            if icon_path.is_empty():
#                continue
#            if script_name == type:
#                return ResourceLoader.load(icon_path, "Texture2D") as Texture2D
#            script_icon_map[script_name] = icon_path

    while not type.is_empty():
        if theme.has_icon(type, theme_type):
            return theme.get_icon(type, theme_type)
        type = ClassDB.get_parent_class(type)
        
    return null


## Returns the icon of [param script] or the nearest parent scripts icon.
## If a valid [param theme] is provided it will also look for the base types
## editor icon if no script icon could be found.
## If no icon could be found [code]null[/code] is returned.
static func get_script_icon(
        script: Script,
        theme: Theme = null,
        theme_type: StringName = "EditorIcons"
) -> Texture2D:
    if not script: return null

    # Match or gather script icon paths
    var script_icon_map: Dictionary[String, String] = {}
    for global_class in ProjectSettings.get_global_class_list():
        var script_path := str(global_class.get("path"))
        if script_path.is_empty():
            continue
        var icon_path := str(global_class.get("icon"))
        if icon_path.is_empty():
            continue
        if script_path == script.resource_path:
            return ResourceLoader.load(icon_path, "Texture2D") as Texture2D
        script_icon_map[script_path] = icon_path

    # Find icon based on parent
    var base_script := script.get_base_script()
    while base_script:
        var script_path := base_script.resource_path
        if script_icon_map.has(script_path):
            var icon_path: String = str(script_icon_map[script_path])
            return ResourceLoader.load(icon_path, "Texture2D") as Texture2D
        base_script = base_script.get_base_script()

    # Find base type editor icon
    if theme:
        var type := script.get_instance_base_type()
        return get_type_icon(type, theme, theme_type)

    return null

#endregion
