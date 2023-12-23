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


var _main_screen: GonzagoEditorMainScreen
var _quickbar: GonzagoEditorQuickbar
var _tool_menu: GonzagoEditorToolMenu


func _init() -> void:
    name = "GonzagoCorePlugin"


func _enter_tree() -> void:
    _main_screen = preload("./editor/main_screen/main_screen.tscn").instantiate() as GonzagoEditorMainScreen
    EditorInterface.get_editor_main_screen().add_child(_main_screen)
    _make_visible(false)

    _quickbar = preload("./editor/quickbar/quickbar.tscn").instantiate() as GonzagoEditorQuickbar
    add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _quickbar)
    var quickbar_parent := _quickbar.get_parent()
    quickbar_parent.move_child(_quickbar, quickbar_parent.get_child_count() - 2)

    _tool_menu = GonzagoEditorToolMenu.new()
    _tool_menu.menu_changed.connect(
        func() -> void:
            if _tool_menu.item_count > 0:
                if not _tool_menu.is_inside_tree():
                    add_tool_submenu_item("Gonzago", _tool_menu)
            elif _tool_menu.is_inside_tree():
                remove_tool_menu_item("Gonzago")
    )


func _exit_tree() -> void:
    if _main_screen:
        _main_screen.queue_free()

    if _quickbar:
        remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _quickbar)
        _quickbar.queue_free()

    if _tool_menu:
        if _tool_menu.is_inside_tree():
            remove_tool_menu_item("Gonzago")
        else:
            _tool_menu.queue_free()


func _has_main_screen() -> bool:
    return true


func _make_visible(visible: bool) -> void:
    if _main_screen:
        _main_screen.visible = visible


func _get_plugin_name() -> String:
    return "Gonzago"


func _get_plugin_icon() -> Texture2D:
    return preload("uid://641b4h8qe3jb") # ./editor/icons/gonzago.svg
