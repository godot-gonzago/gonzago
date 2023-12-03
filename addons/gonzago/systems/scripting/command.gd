@tool
class_name GonzagoCommand
extends Resource
## Base class for Gonzago script commands.


func validate(arguments: Array) -> bool:
    return true


func run(arguments: Array) -> void:
    pass


func can_interupt() -> bool:
    return false


func interupt() -> void:
    pass
