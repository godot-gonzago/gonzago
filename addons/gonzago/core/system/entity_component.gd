@tool
class_name GonzagoEntityComponent
extends Node

## The general group this node gets added to.
const GONZAGO_ENTITY_COMPONENT_GROUP := &"gonzago.entity_component"


func _ready() -> void:
    add_to_group(GONZAGO_ENTITY_COMPONENT_GROUP, true)
