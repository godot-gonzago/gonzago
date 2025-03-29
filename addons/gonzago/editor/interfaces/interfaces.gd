@tool
@static_unload
class_name GonzagoEditorInterface
extends RefCounted
## Editor interface utilities and access to central Gonzago editor interface.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

## Class reference of Gonzago editor control used for main screen plugin.
const MainScreen := preload("./main_screen.gd")
## Class reference of Gonzago editor control used for quickbar in the top right corner.
const Quickbar := preload("./quickbar.gd")
## Class reference of Gonzago editor tool menu under
## [code]Project > Tools[/code] that allows for submenus.
const ToolMenu := preload("./tool_menu.gd")
## Class reference of Gonzago editor control used for about dialog.
const AboutDialog := preload("./about_dialog.gd")

static var _main_screen: MainScreen
static var _quickbar: Quickbar
static var _tool_menu: ToolMenu


## Returns the main screen control of the Gonzago editor.
## If it does not yet exists this method will create an instance of it that is
## not yet part of the scene tree. Gonzago's main plugin will add it once it's
## loaded.
static func get_main_screen() -> MainScreen:
    if _main_screen:
        return _main_screen
        
    var owner := EditorInterface.get_editor_main_screen()
    _main_screen = owner.get_node_or_null("%GonzagoEditorMainScreen") as MainScreen
    if not _main_screen:
            _main_screen = preload("./main_screen.tscn").instantiate() as MainScreen # TODO: Only for testing. Replace with script!
            _main_screen.name = "GonzagoEditorMainScreen"
            _main_screen.unique_name_in_owner = true
    return _main_screen


## Returns the quickbar control of the Gonzago editor.
## If it does not yet exists this method will create an instance of it that is
## not yet part of the scene tree. Gonzago's main plugin will add it once it's
## loaded.
static func get_quickbar() -> Quickbar:
    if _quickbar:
        return _quickbar
    
    var owner := EditorInterface.get_base_control()
    _quickbar = owner.get_node_or_null("%GonzagoEditorQuickbar") as Quickbar
    if not _quickbar:
        _quickbar = Quickbar.new()
        _quickbar.name = "GonzagoEditorQuickbar"
        _quickbar.unique_name_in_owner = true
    return _quickbar


## Returns the tool menu control of the Gonzago editor.
## If it does not yet exists this method will create an instance of it that is
## not yet part of the scene tree. Gonzago's main plugin will add it once it's
## loaded.
static func get_tool_menu() -> ToolMenu:
    if _tool_menu:
        return _tool_menu
    
    var owner := EditorInterface.get_base_control()
    _tool_menu = owner.get_node_or_null("%GonzagoEditorToolMenu") as ToolMenu
    if not _tool_menu:
        _tool_menu = ToolMenu.new()
        _tool_menu.name = "GonzagoEditorToolMenu"
        _tool_menu.unique_name_in_owner = true
    return _tool_menu
