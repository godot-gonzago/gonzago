@tool
class_name GonzagoSystem
extends Node
## Base class for Gonzago systems.
##
## Systems can be loaded or unloaded based on
## application state or feature flags.
## Systems are kept alive as long as the
## instantiating application state or a substate
## thereof is active.

## The general system group this node gets added to.
const GONZAGO_SYSTEM_GROUP := &"gonzago.system"


func _ready() -> void:
    add_to_group(GONZAGO_SYSTEM_GROUP, true)
