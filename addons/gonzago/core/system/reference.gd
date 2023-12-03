@tool
class_name GonzagoReference
extends RefCounted
## Base class for referencable Gonzago objects.
##
## This is used to register Gonzago objects for scripting
## and maybe persistency. Returns an id and instance information,
## as well as properties, commands etc.
## It abstracts away components and extensions.
## Used in stuff like systems, rooms, characters, items, music, etc.


func get_id() -> StringName:
    return &""
