@tool
extends EditorPlugin


const MainScreen := preload("uid://by3djuu8xgi3u")
const Quickbar := preload("uid://caojpa8dr04qw")
const ToolMenu := preload("uid://cg0jn6fcroft")


var _main_screen: MainScreen
var _quickbar: Quickbar
var _tool_menu: ToolMenu


func _enter_tree() -> void:
    var editor_main_screen := EditorInterface.get_editor_main_screen()
    _main_screen = GonzagoEditorInterface.get_main_screen()
    if not _main_screen.is_inside_tree():
        editor_main_screen.add_child(_main_screen)
        _main_screen.owner = editor_main_screen
    _make_visible(false)

    var editor_base_control := EditorInterface.get_base_control()
    _quickbar = GonzagoEditorInterface.get_quickbar()
    if not _quickbar.is_inside_tree():
        add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, _quickbar)
        _quickbar.owner = editor_base_control

    _tool_menu = GonzagoEditorInterface.get_tool_menu()
    _tool_menu.menu_changed.connect(
        func() -> void:
            # Auto show and hide
            if _tool_menu.item_count > 0:
                if not _tool_menu.is_inside_tree():
                    add_tool_submenu_item(_get_plugin_name(), _tool_menu)
                    _tool_menu.owner = editor_base_control
            elif _tool_menu.is_inside_tree():
                remove_tool_menu_item(_get_plugin_name())
    )


func _exit_tree() -> void:
    pass
    #if _main_screen:
        #EditorInterface.get_editor_main_screen().remove_child(_main_screen)
        # TODO: Handle deregistration
        #_main_screen.queue_free()

    #if _quickbar:
        #remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, _quickbar)
        # TODO: Handle deregistration
        #_quickbar.queue_free()

    #if _tool_menu:
        #if _tool_menu.is_inside_tree():
            #remove_tool_menu_item(_get_plugin_name())
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
    return GonzagoEditor.GonzagoIcon
