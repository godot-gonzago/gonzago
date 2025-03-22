@tool
class_name GonzagoEditorInterface
extends EditorPlugin

## Editor interface utilities and access to central Gonzago editor interface.


const MainScreen := preload("./main_screen.gd")
const Quickbar := preload("./quickbar.gd")
const ToolMenu := preload("./tool_menu.gd")


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


static func get_plugin_instance_or_null() -> GonzagoEditorInterface:
    var tree := Engine.get_main_loop() as SceneTree
    var owner := tree.root
    var plugin := owner.get_node_or_null("%GonzagoEditorInterface") as GonzagoEditorInterface
    return plugin
    

func _init() -> void:
    name = "GonzagoEditorInterface"
    unique_name_in_owner = true


func _enter_tree() -> void:
    var root := get_tree().root
    owner = root
    
    var editor_main_screen := EditorInterface.get_editor_main_screen()
    var main_screen := get_main_screen()
    editor_main_screen.add_child(main_screen)
    main_screen.owner = editor_main_screen
    _make_visible(false)

    var editor_base_control := EditorInterface.get_base_control()
    var quickbar = get_quickbar()
    add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, quickbar)
    quickbar.owner = editor_base_control

    var tool_menu = get_tool_menu()
    tool_menu.menu_changed.connect(
        func() -> void:
            # Auto show and hide
            if tool_menu.item_count > 0:
                if not tool_menu.is_inside_tree():
                    add_tool_submenu_item(_get_plugin_name(), tool_menu)
                    tool_menu.owner = editor_base_control
            elif tool_menu.is_inside_tree():
                remove_tool_menu_item(_get_plugin_name())
    )


func _exit_tree() -> void:
    if _main_screen:
        EditorInterface.get_editor_main_screen().remove_child(_main_screen)
        # TODO: Handle deregistration
        #_main_screen.queue_free()

    if _quickbar:
        remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _quickbar)
        # TODO: Handle deregistration
        #_quickbar.queue_free()

    if _tool_menu:
        if _tool_menu.is_inside_tree():
            remove_tool_menu_item(_get_plugin_name())
        # TODO: Handle deregistration
        #else:
        #    _tool_menu.queue_free()


func _has_main_screen() -> bool:
    return true


func _make_visible(visible: bool) -> void:
    if _main_screen:
        _main_screen.visible = visible


func _get_plugin_name() -> String:
    return "Gonzago"


func _get_plugin_icon() -> Texture2D:
    return load("res://addons/gonzago/editor/icons/gonzago.svg") as Texture2D # ./editor/icons/gonzago.svg
