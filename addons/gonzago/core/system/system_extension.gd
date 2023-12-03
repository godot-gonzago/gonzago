@tool
class_name GonzagoSystemExtension
extends Node
## Base class for Gonzago system extensions.

## The general system extension group this node gets added to.
const GONZAGO_SYSTEM_EXTENSION_GROUP := &"gonzago.system_extension"


func _ready() -> void:
    add_to_group(GONZAGO_SYSTEM_EXTENSION_GROUP, true)
