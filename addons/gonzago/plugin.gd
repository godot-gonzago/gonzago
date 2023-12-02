@tool
extends EditorPlugin


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


func _init() -> void:
    name = "GonzagoCorePlugin"


func _enter_tree() -> void:
    pass


func _exit_tree() -> void:
    pass


func _has_main_screen() -> bool:
    return true


func _get_plugin_name() -> String:
    return "Gonzago"


func _get_plugin_icon() -> Texture2D:
    return preload("./editor/icons/gonzago.svg")
