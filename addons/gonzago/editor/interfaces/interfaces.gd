@tool
@static_unload
class_name GonzagoEditorInterface
extends RefCounted

## Editor interface utilities and access to central Gonzago editor interface.


const MainScreen := preload("./main_screen.gd")
const Quickbar := preload("./quickbar.gd")
const ToolMenu := preload("./tool_menu.gd")
const AboutDialog := preload("./about_dialog.gd")


static var _main_screen: MainScreen
static var _quickbar: Quickbar
static var _tool_menu: ToolMenu


static func get_main_screen() -> MainScreen:
    if _main_screen:
        return _main_screen
        
    var owner := EditorInterface.get_editor_main_screen()
    _main_screen = owner.get_node_or_null("%GonzagoEditorMainScreen") as MainScreen
    if not _main_screen:
            _main_screen = preload("./main_screen.tscn").instantiate() as MainScreen
            _main_screen.name = "GonzagoEditorMainScreen"
            _main_screen.unique_name_in_owner = true
            
    return _main_screen


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
