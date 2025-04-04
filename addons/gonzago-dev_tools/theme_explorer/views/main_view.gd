@tool
extends VBoxContainer

const FileBar := preload("./file_bar.gd")
const TypesTree := preload("./items/types_tree.gd")
const ItemsTree := preload("./items/items_tree.gd")

const ImportDialog := preload("./tools/import_dialog.gd")
const ImportDialogScene := preload("./tools/import_dialog.tscn")
const ExportDialog := preload("./tools/export_dialog.gd")
const ExportDialogScene := preload("./tools/export_dialog.tscn")

@onready var file_bar := get_node("ToolBar/FileBar") as FileBar
@onready var type_tree := get_node("ItemsView/TypesTree") as TypesTree
@onready var items_tree := get_node("ItemsView/Split/ItemsTree") as ItemsTree
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
    type_tree.inspect(_theme)


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
    type_tree.inspect(_theme)
    items_tree.inspect(_theme, StringName())


func _on_types_tree_theme_type_selected(theme_type: StringName) -> void:
    items_tree.inspect(_theme, theme_type)
