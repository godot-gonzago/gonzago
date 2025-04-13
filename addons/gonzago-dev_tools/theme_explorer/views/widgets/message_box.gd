@tool
extends AcceptDialog

const NodeUtil := Gonzago.NodeUtil
const _Self := preload("uid://kxasjqh1gf3b")
const _SelfScene := preload("uid://bfemi7pfxbc4p")

#enum MessageType {
#    BASIC, # No icon if none set
#    INFO, # get_theme_icon("Info", "EditorIcons")
#    STATUS_SUCCESS, # get_theme_icon("StatusSuccess", "EditorIcons")
#    STATUS_WARNING, # get_theme_icon("StatusWarning", "EditorIcons")
#    STATUS_ERROR, # get_theme_icon("StatusError", "EditorIcons")
#    FILE, # get_theme_icon("File", "EditorIcons")
#    FILE_BROKEN, # get_theme_icon("FileBroken", "EditorIcons")
#    FILE_DEAD, # get_theme_icon("FileDead", "EditorIcons")
#    FOLDER, # get_theme_icon("Folder", "EditorIcons")
#    MISSING_RESOURCE, # get_theme_icon("MissingResource", "EditorIcons")
#    IMPORT_CHECK, # get_theme_icon("ImportCheck", "EditorIcons")
#    IMPORT_FAIL, # get_theme_icon("ImportFail", "EditorIcons")
#    HEART # get_theme_icon("Heart", "EditorIcons")
#}

#@export var auto_free: bool = true
#@export var icon: Texture2D = null
#@export var message: String = ""

#@onready var _icon := get_node("%Icon") as TextureRect
#@onready var _label := get_node("%Label") as RichTextLabel

#func _ready() -> void:
#    set_unparent_when_invisible(true)


func popup_message_box() -> void:
    if NodeUtil.is_node_being_edited(self):
        return
    
    if Engine.is_editor_hint():
        EditorInterface.popup_dialog_centered(self)
    else:
        var main_window := Engine.get_main_loop().root as Window
        #var window := get_last_exclusive_window()
        popup_exclusive_centered(main_window)


static func show_message(message: String, title: String = "") -> void:
    var messsage_box := _SelfScene.instantiate() as _Self
    messsage_box.dialog_text = message
    if not title.is_empty():
        messsage_box.title = title
    messsage_box.popup_message_box()
