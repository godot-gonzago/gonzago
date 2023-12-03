@tool
class_name GonzagoEngine
extends Node
## Gonzago autoload singleton

## The general group this node gets added to.
const GONZAGO_ENGINE_GROUP := &"gonzago.engine"


func _ready() -> void:
    add_to_group(GONZAGO_ENGINE_GROUP, true)
