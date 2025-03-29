@tool
extends HBoxContainer

@onready var _createButton := get_node("CreateButton") as Button
@onready var _openButton := get_node("OpenButton") as Button
@onready var _saveButton := get_node("SaveButton") as Button

@export_storage var _can_create := true
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var can_create: bool:
    get:
        return _can_create
    set(value):
        if _createButton:
            _createButton.visible = value
        _can_create = value

@export_storage var _can_open := true
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var can_open: bool:
    get:
        return _can_open
    set(value):
        if _openButton:
            _openButton.visible = value
        _can_open = value

@export_storage var _can_save := true
@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_EDITOR)
var can_save: bool:
    get:
        return _can_save
    set(value):
        if _saveButton:
            _saveButton.visible = value
        _can_save = value


func _ready() -> void:
    _createButton.visible = _can_create
    _openButton.visible = _can_open
    _saveButton.visible = _can_save
