@tool
@static_unload
class_name GonzagoEditor
extends RefCounted

## Editor utilities and access to central Gonzago editor interface.


static var _main_screen: GonzagoEditorMainScreen
static var _quickbar: GonzagoEditorQuickbar
static var _tool_menu: GonzagoEditorToolMenu


static func get_main_screen() -> GonzagoEditorMainScreen:
    if _main_screen:
        return _main_screen
        
    var owner := EditorInterface.get_editor_main_screen()
    _main_screen = owner.get_node_or_null("%GonzagoEditorMainScreen") as GonzagoEditorMainScreen
    if not _main_screen:
            _main_screen = preload("./main_screen/main_screen.tscn").instantiate() as GonzagoEditorMainScreen
            _main_screen.name = "GonzagoEditorMainScreen"
            _main_screen.unique_name_in_owner = true
            
    return _main_screen


static func get_quickbar() -> GonzagoEditorQuickbar:
    if _quickbar:
        return _quickbar
    
    var owner := EditorInterface.get_base_control()
    _quickbar = owner.get_node_or_null("%GonzagoEditorQuickbar") as GonzagoEditorQuickbar
    if not _quickbar:
        _quickbar = preload("./quickbar/quickbar.tscn").instantiate() as GonzagoEditorQuickbar
        _quickbar.name = "GonzagoEditorQuickbar"
        _quickbar.unique_name_in_owner = true
        
    return _quickbar


static func get_tool_menu() -> GonzagoEditorToolMenu:
    if _tool_menu:
        return _tool_menu
    
    var owner := EditorInterface.get_base_control()
    _tool_menu = owner.get_node_or_null("%GonzagoEditorToolMenu") as GonzagoEditorToolMenu
    if not _tool_menu:
        _tool_menu = GonzagoEditorToolMenu.new()
        _tool_menu.name = "GonzagoEditorToolMenu"
        _tool_menu.unique_name_in_owner = true
        
    return _tool_menu
