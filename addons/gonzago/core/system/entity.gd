@tool
class_name GonzagoEntity
extends Node
## Base class for adressable Gonzago entities.
##
## Entities are part of the game and might be used
## to persist data. It allows for objects that are not
## directly part of the scene to still persist in the game.
## Like systems, rooms, characters, items, music, etc.

## The general group this node gets added to.
const GONZAGO_ENTITY_GROUP := &"gonzago.entity"


func _ready() -> void:
    add_to_group(GONZAGO_ENTITY_GROUP, true)
