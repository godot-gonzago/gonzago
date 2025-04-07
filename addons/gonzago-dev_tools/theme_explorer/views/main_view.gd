@tool
extends VBoxContainer

const FileBar := preload("uid://bagfm53o5qr5m")
const ItemsView := preload("uid://dd44pss4hfxoy")

const ImportDialog := preload("uid://durgexe8t7ntp")
const ImportDialogScene := preload("uid://dd5vq37p0ovcx")
const ExportDialog := preload("uid://kapj306un40d")
const ExportDialogScene := preload("uid://cjcaygvr2l8je")

@onready var file_bar := get_node("ToolBar/FileBar") as FileBar
@onready var items_view := get_node("ItemsView") as ItemsView
@onready var tools_button := get_node("ToolBar/ToolsButton") as MenuButton

var _import_dialog: ImportDialog
var _export_dialog: ExportDialog

var _theme: Theme


func _ready() -> void:
    _import_dialog = ImportDialogScene.instantiate() as ImportDialog
    _import_dialog.set_unparent_when_invisible(true)
    _export_dialog = ExportDialogScene.instantiate() as ExportDialog
    _export_dialog.set_unparent_when_invisible(true)
    tools_button.get_popup().index_pressed.connect(_on_tools_button_index_pressed)
    
    _theme = file_bar.get_current_theme()
    items_view.inspect(_theme)


func _notification(what: int) -> void:
    match what:
        NOTIFICATION_PREDELETE:
            if _import_dialog: _import_dialog.queue_free()
            if _export_dialog: _export_dialog.queue_free()


func _on_tools_button_index_pressed(index: int) -> void:
    match index:
        0:
            EditorInterface.popup_dialog_centered_ratio(_import_dialog, 0.6)
        1:
            EditorInterface.popup_dialog_centered_ratio(_export_dialog, 0.6)


func _on_theme_selected(theme: Theme) -> void:
    _theme = theme
    items_view.inspect(_theme)
