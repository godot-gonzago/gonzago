@tool
class_name GonzagoMainEditorPlugin
extends EditorPlugin

## Gonzago core editor plugin.
##
## Gonzago Core Framework
## Systems can have extentions that add functionality.
## Scene Objects and Data Objects can have components
## to enhance their functionality and their data.
## Scene object order and their property scope is as follows:
## World (might be a case in a detective game) > Room > Interactable
## Scene objects have properties and a state machine by default
## Scene objects and Data Objects can be identified by an entity object?
## Systems, scene objects and data objects and their components
## provide commands (that are bound to the instance), conditions and events.
## Actor characters can have a costume component, that changes their appearance.
## Player character are only playable and only one is actively controlled by the player.
## Each player character has their own inventory and has to give
## items to other characters for them to use them.
## Items data objects can have scripts that determine their crafting behaviour?
## Maybe Inventory Items (these will be scene objects) are better suited for that.
## 2D/3D will be interchangable with abstraction objects.
## Systems can be overriden by a different implementation or simply just extended.
## Extentions can add new component types to data objects?


signal initialized
signal pre_delete
signal enabled
signal disabled


static func get_plugin_instance_or_null() -> GonzagoMainEditorPlugin:
    var tree := Engine.get_main_loop() as SceneTree
    var owner := tree.root
    var plugin := owner.get_node_or_null("%GonzagoMainEditorPlugin") as GonzagoMainEditorPlugin
    return plugin


func _init() -> void:
    name = "GonzagoMainEditorPlugin"
    unique_name_in_owner = true


func _enter_tree() -> void:
    print("Enter tree GonzagoMainEditorPlugin")

    var root := get_tree().root
    owner = root

    if not ProjectSettings.has_setting("application/boot_splash/screens"):
        ProjectSettings.set("application/boot_splash/screens", [
            "res://addons/gonzago/assets/godot-logo.svg",
            "res://addons/gonzago/assets/gonzago-logo.svg"
        ])
        ProjectSettings.set_as_basic("application/boot_splash/screens", true)
        ProjectSettings.add_property_info({
            "name": "application/boot_splash/screens",
            "type": TYPE_PACKED_STRING_ARRAY ,
            "hint": PROPERTY_HINT_TYPE_STRING,
            "hint_string": "%d/%d:%s" % [
                TYPE_STRING,
                PROPERTY_HINT_FILE,
                "*."+",*.".join(ResourceLoader.get_recognized_extensions_for_type("Texture2D"))
            ]
        })
        ProjectSettings.set_initial_value("application/boot_splash/screens", [])
        ProjectSettings.save()


func _exit_tree() -> void:
    print("Exit tree GonzagoMainEditorPlugin")
    pass


func _enable_plugin() -> void:
    print("Enabled GonzagoMainEditorPlugin")
    EditorInterface.set_plugin_enabled("gonzago/editor/plugins", true)
    EditorInterface.set_plugin_enabled("gonzago/editor/interfaces", true)


func _disable_plugin() -> void:
    print("Disabled GonzagoMainEditorPlugin")
    EditorInterface.set_plugin_enabled("gonzago/editor/interfaces", false)
    EditorInterface.set_plugin_enabled("gonzago/editor/plugins", false)
