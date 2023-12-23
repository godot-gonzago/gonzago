@tool
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

var _main_screen: GonzagoEditorMainScreen
var _tool_menu: PopupMenu


func _init() -> void:
    name = "GonzagoCorePlugin"


func _enter_tree() -> void:
    _main_screen = preload("./editor/main/main_screen.tscn").instantiate() as GonzagoEditorMainScreen
    EditorInterface.get_editor_main_screen().add_child(_main_screen)
    _make_visible(false)

    _tool_menu = PopupMenu.new()
    add_tool_submenu_item("Gonzago", _tool_menu)


func _exit_tree() -> void:
    if _main_screen:
        _main_screen.queue_free()

    remove_tool_menu_item("Gonzago")


func _has_main_screen() -> bool:
    return true


func _make_visible(visible: bool) -> void:
    if _main_screen:
        _main_screen.visible = visible


func _get_plugin_name() -> String:
    return "Gonzago"


func _get_plugin_icon() -> Texture2D:
    return preload("uid://641b4h8qe3jb") # ./editor/icons/gonzago.svg
