@tool
class_name GonzagoEntityExtension
extends Node

## The general group this node gets added to.
const GONZAGO_ENTITY_EXTENSION_GROUP := &"gonzago.entity_extension"


func _ready() -> void:
    add_to_group(GONZAGO_ENTITY_EXTENSION_GROUP, true)
