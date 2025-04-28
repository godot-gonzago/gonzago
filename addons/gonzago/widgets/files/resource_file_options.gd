@tool
extends PopupMenu

# https://github.com/godotengine/godot/blob/master/editor/editor_resource_picker.h#L66

enum MenuOption {
    OBJ_MENU_LOAD,
    OBJ_MENU_QUICKLOAD,
    OBJ_MENU_INSPECT,
    OBJ_MENU_CLEAR,
    OBJ_MENU_MAKE_UNIQUE,
    OBJ_MENU_MAKE_UNIQUE_RECURSIVE,
    OBJ_MENU_SAVE,
    OBJ_MENU_SAVE_AS,
    OBJ_MENU_COPY,
    OBJ_MENU_PASTE,
    OBJ_MENU_SHOW_IN_FILE_SYSTEM,

    TYPE_BASE_ID = 100,
    CONVERT_BASE_ID = 1000,
}
