@tool
extends Node
## Gonzago autoload singleton
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

## The general group this node gets added to.
const GONZAGO_ENGINE_GROUP := &"gonzago.engine"


func _ready() -> void:
    add_to_group(GONZAGO_ENGINE_GROUP, true)
